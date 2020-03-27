class EvaluationResult < BaseModel
  after_create :create_callback
  after_destroy :destroy_callback

  serialize :links, Array
  attr_accessor :result_dependances_ids

  IMPACT_TYPES = ["", "none", "noticeable", "disruptive", "serious"]
  ASSESSMENT_STATUSES = [:no_action, :medium, :urgent, :need_for_action]
  SERVICE_STATUSES = [:ignored, :deactivated, :active, :draft]

  belongs_to :evaluation
  belongs_to :company_branch
  belongs_to :service

  belongs_to :created, foreign_key: :created_by, class_name: "User"
  belongs_to :updated, foreign_key: :updated_by, class_name: "User"

  has_many :evaluation_result_company_branches, dependent: :destroy
  has_many :company_branches, through: :evaluation_result_company_branches
  has_many :evaluation_result_servers, dependent: :destroy
  has_many :evaluation_result_appliances, dependent: :destroy
  has_many :evaluation_result_files, dependent: :destroy
  has_many :evaluation_process_results, dependent: :destroy

  has_many :employee_evaluation_results, dependent: :destroy


  has_many :evaluation_result_service_dependances, dependent: :destroy


  accepts_nested_attributes_for :evaluation_result_servers, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :evaluation_result_appliances, allow_destroy: true, reject_if: :all_blank

  validates :company_branch_id, :presence => { message: I18n.t('evaluation_results.add_and_select_at_least_one_location') }
  validates :service, presence: true

  scope :active, -> { where(service_status: SERVICE_STATUSES.index(:active)) }
  scope :ignored, -> { where(service_status: SERVICE_STATUSES.index(:ignored)) }
  scope :deactivated, -> { where(service_status: SERVICE_STATUSES.index(:deactivated)) }
  scope :draft, -> { where(service_status: SERVICE_STATUSES.index(:draft)) }

  scope :cloned, -> { where("cloned_index != '' AND cloned_index != '.01'") }

  def is_active?
    self.status_name == :active
  end

  def is_ignored?
    self.status_name == :ignored
  end

  def is_deactivated?
    self.status_name == :deactivated
  end

  def is_cloned?
    self.cloned_index.present?
  end

  def status_name
    SERVICE_STATUSES[self.service_status]
  end

  def impact_name
    IMPACT_TYPES[self.impact] || ''
  end

  def evaluation_service
    self.evaluation.evaluation_services.where(service_id: self.service_id, cloned_index: self.cloned_index).first
  end

  def result_dependant_services
    services = []
    evaluation_result_service_dependances.where('service_id=? AND service_depending_id in (?)', service, evaluation.evaluation_results.active.pluck(:service_id)).includes(:service_depending).each do |a|
      services << a.service_depending
    end

    services
  end

  def result_depending_services
    # service.inverse_dependings.where('services.id in (?)', evaluation.evaluation_results.active.pluck(:service_id))
    services = []
    evaluation_result_service_dependances.where('service_depending_id=? AND service_id in (?)', service, evaluation.evaluation_results.active.pluck(:service_id)).includes(:service).each do |a|
      services << a.service
    end

    services
  end

  def sla
    if self.recovery_time.present? and self.recovery_time > 0
      (1.0/self.recovery_time).round(2)
    else
      0
    end
  end

  def clone_evaluation_result
    if cloned_index.blank?
      update_attribute(:cloned_index, generate_cloned_index(1))
      es = self.evaluation.evaluation_services.where(service_id: service_id).first
      es.update_attribute(:cloned_index, generate_cloned_index(1))
    end

    last_cloned_index = self.class.where(evaluation_id: evaluation_id, service_id: service_id).order('cloned_index DESC').first.cloned_index

    cloned_obj = deep_clone(include: [
        :company_branches,
        :evaluation_result_servers,
        :evaluation_result_files,
        :evaluation_process_results,
        :employee_evaluation_results
    ])

    cloned_obj.cloned_index = generate_cloned_index(last_cloned_index[1..-1].to_i + 1)
    cloned_obj.save!

    es = EvaluationService.where("evaluation_id=?", self.evaluation_id).order(:position).last
    EvaluationService.create(evaluation_id: cloned_obj.evaluation_id, service_id: cloned_obj.service_id, status: cloned_obj.service_status, position:es.position + 1, cloned_index: cloned_obj.cloned_index)
    cloned_obj
  end

  def create_callback
    service.service_dependances.each do |d|
      sd = self.evaluation_result_service_dependances.build(service_id: d.service_id, service_depending_id: d.depending_id)
      sd.save!
    end

    service.inverse_service_dependances.each do |d|
      sd = self.evaluation_result_service_dependances.build(service_id: d.service_id, service_depending_id: d.depending_id)
      sd.save!
    end
  end

  def destroy_callback
    if cloned_index.present? && cloned_index != '.01'
      evaluation_service.destroy!
    end
  end

  private
    def generate_cloned_index index
      ".#{index.to_s.rjust(2, '0')}"
    end

end
