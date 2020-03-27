class Service < BaseModel
  acts_as_list

  default_scope { where(is_disp: true) }

  translates :name, :purpose, :product_examples
  accepts_nested_attributes_for :translations

  has_many :theme_services, dependent: :destroy
  has_many :themes, through: :theme_services

  has_many :industry_services, dependent: :destroy
  has_many :industries, through: :industry_services

  has_many :evaluation_results, dependent: :restrict_with_error
  has_many :evaluation_services, dependent: :destroy
  belongs_to :owner, foreign_key: :owner_id, class_name: "Company"

  has_many :service_dependances
  has_many :dependings, through: :service_dependances

  has_many :inverse_service_dependances, class_name: "ServiceDependance", foreign_key: "depending_id"
  has_many :inverse_dependings, through: :inverse_service_dependances, source: :service

  validates :name, :purpose, presence: true
  # validates :code, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: { scope: :is_disp }
end
