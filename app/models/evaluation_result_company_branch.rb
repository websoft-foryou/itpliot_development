class EvaluationResultCompanyBranch < BaseModel

	belongs_to :evaluation_result
	belongs_to :company_branch

	# TODO: It was commented temporarily to fix https://medialineeurotradesrl.eu.teamwork.com/#tasks/13672404?c=6419593
	# validates :company_branch_id, :evaluation_result_id, presence: true, uniqueness: {scope: [:company_branch_id, :evaluation_result_id]}

end
