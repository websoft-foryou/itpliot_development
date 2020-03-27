class Location < BaseModel
  belongs_to :company_branch
  belongs_to :company

  after_initialize :set_default_values, unless: :persisted?

  COUNTRIES = ["Austria","Belgium","Bosnia and Herzegowina","Bulgaria","Croatia","Cyprus","Czech Republic","Denmark","Finland","France","Germany","Greece","Hungary","Ireland","Italy","Luxembourg","Netherlands","Norway","Poland","Romania","Serbia","Slovakia","Slovenia","Spain","Sweden","Switzerland","United Kingdom"]

  validates :city, :country, :zip, presence: true
  validates :address, presence: true, uniqueness: { scope: [:company_id, :company_branch_id] }

  default_scope { order(:id) }

  def full_address
    [self.address,"#{self.zip} #{self.city}",self.country].compact.join(', ') || nil
  end

  def set_default_values
    self.country  ||= 'Germany'
  end
end
