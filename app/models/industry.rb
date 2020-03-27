class Industry < BaseModel

	has_many :industry_services, dependent: :destroy
	has_many :services, through: :industry_services

	validates :name, :name_de, :short_name_en, :short_name_de, presence: true


end
