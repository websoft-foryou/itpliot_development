class Employee < BaseModel
  # after_save :update_draft_employee_evaluation

  WORK_TYPES = [:internal, :external]

  belongs_to :customer, class_name: "Company"
  has_many :employee_evaluation_results, dependent: :restrict_with_exception
  has_many :employee_domains, dependent: :destroy
  has_many :employee_evaluations, dependent: :destroy

  validates :customer_id, presence: true
  validates :current_first_name, presence: true
  validates :current_last_name, presence: true

  scope :enabled, ->{ where('disabled_at IS NULL') }

  def current_work_type_name
    WORK_TYPES[self.current_work_type].to_s
  end

  WORK_TYPES.each.with_index do |work, i|
    define_method "is_current_#{work}?" do
      self.current_work_type == i
    end
  end

  def is_enabled?
    disabled_at.nil?
  end

  def is_disabled?
    !is_enabled?
  end

  def disable
    touch(:disabled_at)
    employee_evaluations.joins(:evaluation).where('evaluations.status = 0').destroy_all
    employee_evaluation_results.joins(evaluation_result: :evaluation).where('evaluations.status = 0').destroy_all
  end


  private
    def update_draft_employee_evaluation
      return unless customer
      draft_evaluation = self.customer.customer_evaluations.drafts.not_sandbox.first
      return unless draft_evaluation
      rec = employee_evaluations.where(evaluation_id: draft_evaluation.id).first_or_create
      rec.update_attributes(employee_first_name: self.current_first_name, employee_last_name: self.current_last_name, employee_work_type: self.current_work_type,employee_monthly_hours: self.current_monthly_hours)
    end
end
