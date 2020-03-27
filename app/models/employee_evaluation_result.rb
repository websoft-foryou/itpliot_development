class EmployeeEvaluationResult < BaseModel

  ACTIVITY_TYPES = {
    'e' => 'evaluation_and_planning',
    't' => 'test',
    'o' => 'order_management',
    'v' => 'vendor_management',
    'i' => 'instalation',
    'c' => 'configuration',
    'a' => 'administration',
    'm' => 'monitoring',
    'u' => 'updates',
    'l1' => 'level1_support',
    'l2' => 'level2_support',
    'l3'  =>'level3_support'
  }

  belongs_to :employee
  belongs_to :evaluation_result

  # validates :evaluation_result_id, presence: true, uniqueness: {scope: [:employee_id]}

  def sum_activity
    s = 0
    EmployeeEvaluationResult::ACTIVITY_TYPES.each do |k,v|
      s += 1 if self.send("#{v}")
    end
    s
  end

  def has_any_activity?
    EmployeeEvaluationResult::ACTIVITY_TYPES.any? { |k, v| send(v) }
  end

end
