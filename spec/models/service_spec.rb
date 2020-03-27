require 'rails_helper'

RSpec.describe Service, type: :model do
  let(:service) { create(:service) }

  context 'validations' do
    it 'is valid' do
      expect(service).to be_valid
    end

    it 'requires code field' do
      service.code = ''
      expect(service).to be_invalid
    end

    it 'requires name field' do
      service.name = ''
      expect(service).to be_invalid
    end

    it 'requires purpose field' do
      service.purpose = ''
      expect(service).to be_invalid
    end

    it 'requires unique code' do
      invalid_service = build(:service, code: service.code)

      expect(invalid_service).to be_invalid
      expect(invalid_service.errors[:code]).to_not be_empty
    end
  end

  context 'association' do
    it 'should not allow destroy if associated evaluation_results exists' do
      company_company = create(:company_company)
      customer_company = create(:customer_company, parent_id: company_company.id)
      company_branch = create(:company_branch, company_id: customer_company.id)
      evaluation = create(:evaluation, customer_id: customer_company.id, company_id: company_company.id)
      evaluation_result = evaluation.evaluation_results.create(service_id: service.id, company_branch_id: company_branch.id)

      expect(service.evaluation_results.count).to eq(1)
      expect do
        service.destroy
      end.to change { Service.count }.by(0)
    end

    it 'should not allow destroy if associated evaluation_results exists' do
      company_company = create(:company_company)
      customer_company = create(:customer_company, parent_id: company_company.id)
      company_branch = create(:company_branch, company_id: customer_company.id)
      evaluation = create(:evaluation, customer_id: customer_company.id, company_id: company_company.id)
      evaluation_service = evaluation.evaluation_services.create(service_id: service.id)

      expect(service.evaluation_services.count).to eq(1)
      expect do
        service.destroy
      end.to change { Service.count }.by(0)
    end
  end
end
