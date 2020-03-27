class CompanyBranch < BaseModel

  belongs_to :company
  has_many :company_users, dependent: :destroy
  has_many :users, through: :company_users
  has_many :evaluation_results, dependent: :destroy
  has_one :location, dependent: :destroy

  accepts_nested_attributes_for :location

  validates :name, presence: true, uniqueness: { scope: :company_id }

end
