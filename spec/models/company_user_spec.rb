require 'rails_helper'

RSpec.describe CompanyUser, type: :model do
  let(:customer_user) { create(:customer_user) }
  let(:customer_company) { create(:customer_company) }
  let(:company_user) { create(:company_user, user_id: customer_user.id, company_id: customer_company.id) }

  context 'validations' do
    it 'is valid' do
      expect(company_user).to be_valid
    end

    it 'requires user_id' do
      company_user.user_id = ''

      expect(company_user).to be_invalid
      expect(company_user.errors[:user_id]).to_not be_empty
    end

    it 'requires company_id' do
      company_user.company_id = ''

      expect(company_user).to be_invalid
      expect(company_user.errors[:company_id]).to_not be_empty
    end

    it 'should be uniq per company' do
      invalid_company_user = build(:company_user, user_id: company_user.user_id, company_id: company_user.company_id)

      expect(invalid_company_user).to be_invalid
      expect(invalid_company_user.errors[:user_id]).to_not be_empty
    end

  end
end
