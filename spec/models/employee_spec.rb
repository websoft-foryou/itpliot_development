require 'rails_helper'

RSpec.describe Employee, type: :model do
  let(:company){ create(:company_company) }
  let(:customer){ create(:customer_company, parent_id: company.id) }
  let(:evaluation){ create(:evaluation, customer_id: customer.id, company_id: customer.parent_id) }
  let(:employee){ create(:employee, customer_id: customer.id) }

  context 'validations' do
    it 'is valid' do
      expect(employee).to be_valid
    end

    it 'requires current_first_name field' do
      employee.current_first_name = ''
      expect(employee).to be_invalid
      expect(employee.errors[:current_first_name]).to_not be_empty
    end

    it 'requires current_last_name field' do
      employee.current_last_name = ''
      expect(employee).to be_invalid
      expect(employee.errors[:current_last_name]).to_not be_empty
    end

    it 'requires customer_id field' do
      employee.customer_id = ''
      expect(employee).to be_invalid
      expect(employee.errors[:customer_id]).to_not be_empty
    end
  end

  context 'callbacks' do
    context 'updates draft employee evaluation' do
      it 'adds employee_evaluation' do
        expect(evaluation.employee_evaluations.count).to eq(0)
        expect do
          employee = create(:employee, customer_id: customer.id)
        end.to change { evaluation.employee_evaluations.count }.by(1)
      end

      it 'updates employee_evaluation for current draft evaluation' do
        draft_evaluation = evaluation
        employee.update_attribute(:current_first_name, 'new name')
        evaluation.employee_evaluations.each do |item|
          expect(item.employee_first_name).to eq('new name')
        end
      end

      it 'leaves employee_evaluation unchanged for published evaluation' do
        first_evaluation = create(:evaluation, customer_id: customer.id, company_id: customer.parent_id)
        employee = create(:employee, customer_id: customer.id)
        first_evaluation.update_attribute(:status, Evaluation::STATUSES.index('published'))

        published_evaluation = first_evaluation
        draft_evaluation = evaluation

        expect(employee.employee_evaluations.count).to eq(2)
        expect(published_evaluation.employee_evaluations.count).to eq(1)
        expect(draft_evaluation.employee_evaluations.count).to eq(1)

        old_employee_name = employee.current_first_name
        employee.update_attribute(:current_first_name, 'new name')
        expect(employee.current_first_name).not_to eq(old_employee_name)

        published_evaluation.employee_evaluations.each do |item|
          expect(item.employee_first_name).to eq(old_employee_name)
        end

        draft_evaluation.employee_evaluations.each do |item|
          expect(item.employee_first_name).to eq('new name')
        end
      end
    end
  end

  describe 'public methods' do
    context 'responds to methods' do
      it { expect(employee).to respond_to(:disable) }
    end

    context '#disable' do
      it 'deletes draft evaluation employee_evaluations' do
        first_evaluation = create(:evaluation, customer_id: customer.id, company_id: customer.parent_id)
        employee = create(:employee, customer_id: customer.id)
        first_evaluation.update_attribute(:status, Evaluation::STATUSES.index('published'))

        published_evaluation = first_evaluation
        draft_evaluation = evaluation

        expect(employee.disabled_at).to be_nil
        expect(employee.employee_evaluations.count).to eq(2)
        expect(published_evaluation.employee_evaluations.count).to eq(1)
        expect(draft_evaluation.employee_evaluations.count).to eq(1)

        employee.disable
        expect(employee.employee_evaluations.count).to eq(1)
        expect(published_evaluation.employee_evaluations.count).to eq(1)
        expect(draft_evaluation.employee_evaluations.count).to eq(0)
      end
    end
  end

end