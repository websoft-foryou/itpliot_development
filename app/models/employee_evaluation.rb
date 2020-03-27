class EmployeeEvaluation < BaseModel
  belongs_to :evaluation
  belongs_to :employee

  validates :employee_first_name, :employee_last_name, :employee_work_type, :evaluation_id, presence: true
  validates :employee_id, presence: true, uniqueness: {scope: [:evaluation_id]}

  def employee_work_type_name
    Employee::WORK_TYPES[self.employee_work_type].to_s
  end

  Employee::WORK_TYPES.each.with_index do |work, i|
    define_method "was_#{work}?" do
      self.employee_work_type == i
    end
  end

end
