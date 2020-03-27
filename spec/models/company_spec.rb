require "rails_helper"

# - validations presence name, contact_person
# - validations format phone, mobile, url, email

RSpec.describe Company, type: :model do
  let(:company_company){ create(:company_company) }
  let(:customer_company){ create(:customer_company) }

  context "validations" do
    it 'is valid' do
      expect(company_company).to be_valid
    end
    it "requires name field" do
      company_company.name = ''
      expect(company_company).to be_invalid
    end
    it "requires contact_person field" do
      company_company.contact_person = ''
      expect(company_company).to be_invalid
    end
    it "requires phone field" do
      company_company.phone = ''
      expect(company_company).to be_invalid
    end
    it "requires mobile field" do
      company_company.mobile = ''
      expect(company_company).to be_invalid
    end
    it "requires email field" do
      company_company.email = ''
      expect(company_company).to be_invalid
    end
    it "requires a business" do
      company_company.business = nil
      expect(company_company).to be_invalid
    end
    it "must have valid phone/mobile format" do
      invalid_values = ['abc','123','abc123']
      invalid_values.each do |v|
        company_company.phone = v
        expect(company_company).to be_invalid
        expect(company_company.errors[:phone]).to_not be_empty
      end
      invalid_values.each do |v|
        company_company.mobile = v
        expect(company_company).to be_invalid
        expect(company_company.errors[:mobile]).to_not be_empty
      end
    end
    it "must have valid email format" do
      invalid_values = ['asdfa','asdfasf.com','@.']
      invalid_values.each do |v|
        company_company.email = v
        expect(company_company).to be_invalid
        expect(company_company.errors[:email]).to_not be_empty
      end
    end
    it "should have unique vat number" do
      company2 = create(:company_company)
      expect(company2).to be_valid
      company2.vat_number = company_company.vat_number
      expect(company2).to be_invalid
    end
  end

  context "callbacks" do
    it 'adds url protocol' do
      company_company.url = 'smth.com'
      company_company.save
      expect(company_company.url).to eq('http://smth.com')
    end
  end

  describe 'public methods' do
    context 'responds to methods' do
      it { expect(company_company).to respond_to(:has_current_evaluation?) }
      it { expect(company_company).to respond_to(:full_name) }
    end

    context '#has_current_evaluation?' do
      context 'when not a customer_company' do
        it 'returns false for company_company' do
          expect(company_company.has_current_evaluation?).to be false
        end
      end

      context 'when customer_company' do
        it 'returns false if no draft evaluations' do
          expect(customer_company.has_current_evaluation?).to be false
        end

        it 'returns true if has draft evaluations' do
          evaluation = create(:evaluation, customer_id: customer_company.id, company_id: company_company.id)
          expect(customer_company.has_current_evaluation?).to be true
        end
      end
    end

    it '#full_name display name with suffix' do
      customer_company.name2 = 'SRL'

      expect(customer_company.full_name).to eq("#{customer_company.name} #{customer_company.name2}")
    end
  end

end
