class CompanyUser < BaseModel
  belongs_to :company
  belongs_to :company_branch
  belongs_to :user

  validates :user_id, presence: true, uniqueness: {scope: [:company_id, :company_branch_id]}
  validates :company_id, presence: true
end
