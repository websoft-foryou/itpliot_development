class EvaluationResultAppliance < BaseModel
  belongs_to :evaluation_result
  default_scope { order(:id) }
end
