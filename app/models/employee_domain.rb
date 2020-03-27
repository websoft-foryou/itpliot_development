class EmployeeDomain < BaseModel

	belongs_to :employee
	belongs_to :domain
	belongs_to :evaluation

	validates :domain_id, presence: true
	validates :employee_id, presence: true, uniqueness: {scope: [:domain_id, :evaluation_id]}

end
