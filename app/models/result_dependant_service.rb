class ResultDependantService < BaseModel

  belongs_to :evaluation_result, :counter_cache => true
  belongs_to :service

  validates :service_id, :evaluation_result_id, presence: true, uniqueness: {scope: [:service_id, :evaluation_result_id]}

end
