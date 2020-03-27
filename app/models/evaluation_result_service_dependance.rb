class EvaluationResultServiceDependance < BaseModel
  belongs_to :service
  belongs_to :service_depending, :class_name => "Service"
end
