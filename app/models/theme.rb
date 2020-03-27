class Theme < BaseModel
  translates :name

  accepts_nested_attributes_for :translations

  has_many :theme_services, dependent: :destroy
  has_many :services, through: :theme_services

  validates :name, presence: true
end
