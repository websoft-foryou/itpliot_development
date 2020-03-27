class EvaluationDependance < BaseModel

  belongs_to :evaluation

  belongs_to :evaluation_dependant_service, :class_name => "Service", :foreign_key => "dependant_service_id"
  belongs_to :evaluation_depending_service, :class_name => "Service", :foreign_key => "depending_service_id"

  validates :dependant_service_id, presence: true, uniqueness: {scope: [:evaluation_id,:depending_service_id]}

end
