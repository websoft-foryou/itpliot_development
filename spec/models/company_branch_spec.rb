require 'rails_helper'

RSpec.describe CompanyBranch, type: :model do
  let(:location){ create(:location) }
  let(:company_branch){ create(:company_branch) }

  context 'validations' do
    it 'is valid' do
      expect(company_branch).to be_valid
    end

    it 'requires name field' do
      company_branch.name = ''

      expect(company_branch).to be_invalid
      expect(company_branch.errors[:name]).to_not be_empty
    end

    it 'requires name unique for company' do
      invalid_company_branch = build(:company_branch, name: company_branch.name, company_id: company_branch.company_id)

      expect(invalid_company_branch).to be_invalid
      expect(invalid_company_branch[:name]).to_not be_empty
    end
  end
end