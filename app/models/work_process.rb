class WorkProcess < BaseModel

	translates :name
	accepts_nested_attributes_for :translations

	validates :name, presence: true
end
