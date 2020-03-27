class Evaluation < BaseModel

  #after_create :create_default_evaluation_services
  after_create :create_employee_evaluations_copy

  STATUSES = [ "draft", "published" ]
  TYPES = [ :normal, :sample, :sandbox ]

  EMPLOYEE_MAX_COUNT = 15

  belongs_to :company, class_name: "Company"
  belongs_to :customer, class_name: "Company"
  belongs_to :user ,foreign_key: :created_by, class_name: "User"
  belongs_to :update_user, foreign_key: :updated_by, class_name: "User"
  belongs_to :publisher, foreign_key: :published_by, class_name: "User"

  has_many :evaluation_results, dependent: :destroy
  has_many :employee_evaluation_results, through: :evaluation_results
  has_many :pdf_assets, dependent: :destroy
  has_many :evaluation_services, dependent: :destroy
  has_many :evaluation_processes, dependent: :destroy
  has_many :evaluation_process_results, through: :evaluation_processes
  has_many :employee_evaluations, dependent: :destroy

  validates :name, :company_id, :customer_id, presence: true

  accepts_nested_attributes_for :evaluation_results

  scope :drafts, ->{ where(status: STATUSES.index('draft')) }
  scope :published, ->{ where(status: STATUSES.index('published')) }
  scope :not_sandbox, ->{ where(distinguish_type: !TYPES.index(:sandbox)) }
  scope :sandbox, ->{ where(distinguish_type: TYPES.index(:sandbox)) }

  def self.sample_evaluation
    Evaluation.where(distinguish_type: TYPES.index(:sample)).first
  end

  def can_be_published?
    #all active services are added (present) in results and there is at least one active service
    count_to_complete == 0 and active_evaluation_results.any? and ignored_evaluation_results.empty? and draft_evaluation_services.empty? and !is_sandbox?
  end

  def can_show_full_reports?
    #there is no draft ev.result (all are active/ignored/deactivated)
    evaluation_results.where('service_id IN (?)',evaluation_services.draft.pluck(:service_id)).empty?
  end

  def ignored_evaluation_services
    evaluation_services.ignored
  end

  def ignored_evaluation_results
    evaluation_results.ignored
  end

  def draft_evaluation_services
    evaluation_services.draft
  end

  def active_evaluation_results
    evaluation_results.active#.where("cloned_index=? OR cloned_index=?", '', '.01')
  end

  def active_evaluation_services
    evaluation_results.active#.where("cloned_index=? OR cloned_index=?", '', '.01')
  end

  def count_to_complete
    #to complete = evaluation active services, that are still to add in ev.results
    active_evaluation_services.count - active_evaluation_results.count
  end

  def count_completed_ignored
    evaluation_results.where('service_id in (?)',evaluation_services.ignored.pluck(:service_id)).count
  end

  def count_completed_deactivated
    self.evaluation_results.where('service_id in (?)',self.evaluation_services.deactivated.pluck(:service_id)).count
  end

  def status_name
    STATUSES[self.status]
  end

  def type_name
    TYPES[self.distinguish_type]
  end

  def is_draft?
    self.status_name == 'draft'
  end

  def is_normal?
    self.type_name == :normal
  end

  def is_sample?
    self.type_name == :sample
  end

  def is_sandbox?
    self.type_name == :sandbox
  end

  def ignores?(service_id)
    self.evaluation_services.ignored.where('evaluation_services.service_id = (?)',service_id).count > 0
  end

  def has_service_deactivated?(service_id)
    self.evaluation_services.deactivated.where('evaluation_services.service_id = (?)',service_id).count > 0
  end

  def is_published?
    self.status_name == 'published'
  end

  #======== used in reports ==============

  #for draft evaluation: employees are used only if disabled_at is null
  #for published evaluation: employees are used only if disabled_at is null or disabled_at was made after evaluation was published
  def enabled_employees
    if is_published?
      customer.employees.where("employees.disabled_at IS NULL OR (employees.disabled_at > :published_at)", {published_at: published_at})
    else
      customer.employees.where('employees.disabled_at IS NULL')
    end
  end

  #FTE averages
  def sum_hours_extern
    evaluation_results.sum(:hours_extern)
  end

  def sum_hours_intern
    evaluation_results.sum(:hours_intern)
  end

  def average_extern_per_service
    evaluation_results.sum(:hours_extern)/self.evaluation_results.count
  end

  def average_intern_per_service
    evaluation_results.sum(:hours_intern)/self.evaluation_results.count
  end

  def fte_resources_extern
    employee_evaluations.where(employee_work_type: Employee::WORK_TYPES.index(:external)).sum(:employee_monthly_hours)
  end

  def fte_resources_intern
    employee_evaluations.where(employee_work_type: Employee::WORK_TYPES.index(:internal)).sum(:employee_monthly_hours)
  end

  def clone_last_evaluation
    source = self.customer.customer_evaluations.not_sandbox.order('id desc').first
    return self unless source
    clone = source.deep_clone include: [:evaluation_services,
                                        {:evaluation_results => :employee_evaluation_results},
                                        {:evaluation_processes => :evaluation_process_results}],
                                        validate: false
    new_added_services = Service.where("id not in (?)", source.evaluation_services.pluck(:service_id))
    if new_added_services.any?
      new_added_services.each do |s|
        clone.evaluation_services.build(service_id: s.id, position: s.position, status: EvaluationService::STATUSES.index(:active))
      end
    end
    clone
  end

  def clone_evaluation
    cloned_obj = deep_clone include: [:evaluation_services,
                                        {:evaluation_results => :employee_evaluation_results},
                                        {:evaluation_processes => :evaluation_process_results}],
                                        validate: false
    new_added_services = Service.where("id not in (?)", evaluation_services.pluck(:service_id))
    if new_added_services.any?
      new_added_services.each do |s|
        cloned_obj.evaluation_services.build(service_id: s.id, position: s.position, status: EvaluationService::STATUSES.index(:active))
      end
    end
    cloned_obj
  end

  def create_default_evaluation_services
    return unless self.evaluation_services.count == 0
    active_status = EvaluationService::STATUSES.index(:draft)
    Service.all.each do |s|
      self.evaluation_services.build(service_id: s.id, position: s.position, status: active_status)
    end
    self.save!
  end

  private
    def create_employee_evaluations_copy
      customer.employees.where('employees.disabled_at IS NULL').each do |employee|
        ee = employee_evaluations.where(employee_id: employee).first_or_initialize
        ee.employee_first_name = employee.current_first_name.presence || 'First Name'
        ee.employee_last_name = employee.current_last_name.presence || 'Last Name'
        ee.employee_work_type = employee.current_work_type
        ee.employee_monthly_hours = employee.current_monthly_hours
        ee.save!
      end
    end

end
