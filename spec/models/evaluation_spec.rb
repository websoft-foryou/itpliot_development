require "rails_helper"

# - TODO:
# - only one draft evaluation should exist!
# - new evaluation may be created only after all are published
# - and the customer has premium account
# - ambiguous belongs_to company/customer_company, class_name: "Company"

RSpec.describe Evaluation, type: :model do
  let(:company){ create(:company_company) }
  let(:customer){ create(:customer_company, parent_id: company.id) }
  let(:evaluation){ create(:evaluation, customer_id: customer.id, company_id: customer.parent_id) }

  let!(:s1){ create(:service) }
  let!(:s2){ create(:service) }

  context 'validations' do
    it 'is valid' do
      expect(evaluation).to be_valid
    end

    it 'requires name field' do
      evaluation.name = ''
      expect(evaluation).to be_invalid
      expect(evaluation.errors[:name]).to_not be_empty
    end

    it 'requires company_id' do
      evaluation.company = nil
      expect(evaluation).to be_invalid
      expect(evaluation.errors[:company_id]).to_not be_empty
    end

    it 'requires company_id' do
      evaluation.customer = nil
      expect(evaluation).to be_invalid
      expect(evaluation.errors[:customer_id]).to_not be_empty
    end
  end

  context 'callbacks' do
    context 'creates default evaluation services' do
      it 'creates default evaluation services' do
        total_services = Service.count()
        expect(evaluation.evaluation_services.count).to eq(total_services)
      end

      it 'has all default evaluation services draft' do
        evaluation.evaluation_services.each do |s|
          expect(s.status).to eq(EvaluationService::STATUSES.index(:draft))
        end
      end
    end

    context 'creates employee evaluations copy' do

    end
  end

  describe 'public methods' do
    context 'responds to methods' do
      it { expect(evaluation).to respond_to(:clone) }
    end

    context '#clone' do
      context 'when no source exists' do
        it 'returns same object' do
          expect{evaluation.clone_last_evaluation}.to_not change{evaluation}
          expect{evaluation.clone_last_evaluation}.to_not change{evaluation.evaluation_services}
        end
      end

      context 'when source exists' do
        it 'clones source object' do
          source = create(:evaluation, customer_id: customer.id, company_id: customer.parent_id)
          source.evaluation_services.first.update_attribute(:status, EvaluationService::STATUSES.index(:ignored))

          evaluation = create(:evaluation, customer_id: customer.id, company_id: customer.parent_id)
          expect{evaluation = source.clone_last_evaluation}.to change{evaluation.evaluation_services}
        end
      end
    end
  end



end
