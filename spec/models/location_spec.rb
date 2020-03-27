require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:company) { create(:company) }
  let(:location) { create(:location, company_id: company.id) }

  context 'validations' do
    it 'is valid' do
      expect(location).to be_valid
    end

    it 'requires address field' do
      location.address = ''

      expect(location).to be_invalid
      expect(location.errors[:address]).to_not be_empty
    end

    it 'requires unique address within company' do
      invalid_location = build(:location, company_id: company.id, address: location.address)
      
      expect(invalid_location).to be_invalid
      expect(invalid_location.errors[:address]).to_not be_empty
    end

    it 'requires city field' do
      location.city = ''

      expect(location).to be_invalid
      expect(location.errors[:city]).to_not be_empty
    end

    it 'requires country field' do
      location.country = ''

      expect(location).to be_invalid
      expect(location.errors[:country]).to_not be_empty
    end

    it 'requires zip field' do
      location.zip = ''

      expect(location).to be_invalid
      expect(location.errors[:zip]).to_not be_empty
    end
  end
end