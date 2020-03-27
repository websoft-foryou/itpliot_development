class License < BaseModel
  translates :description
  accepts_nested_attributes_for :translations
end
