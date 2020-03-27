class EvaluationProcess < BaseModel
  belongs_to :evaluation
  belongs_to :work_process

  has_many :evaluation_process_results
  has_many :evaluation_result, through: :evaluation_process_results
end
