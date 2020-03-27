require "rails_helper"

# - validates presence first_name,last_name
# - validates uniqueness of email
# - validates format of email
# - validates password complexity
# - user must have a default profile type

RSpec.describe User, type: :model do
  let(:user){build(:user)}
  let(:user_2){build(:user)}

  context "validations" do
    it 'is valid' do
      expect(user).to be_valid
      expect(user_2).to be_valid
    end

    it "should have a valid password format" do
      user.password = '12345678'
      expect(user).to be_invalid
      expect(user.errors[:password]).to_not be_empty
      user.password = 'abcdefgh'
      expect(user).to be_invalid
      expect(user.errors[:password]).to_not be_empty
      user.password = 'aA12345'
      expect(user).to be_invalid
      expect(user.errors[:password]).to_not be_empty
    end

    it "requires name field" do
      user.first_name = ''
      expect(user).to be_invalid
      user.last_name = ''
      expect(user).to be_invalid
      expect(user.errors[:first_name]).to_not be_empty
      expect(user.errors[:last_name]).to_not be_empty
    end

    it "should have a valid email format" do
      user.email = 'invalid_email'
      expect(user).to be_invalid
      expect(user.errors[:email]).to_not be_empty
    end

    it "shoud have an unique email" do
      user_2.skip_confirmation!
      user_2.save!
      user.email = user_2.email
      expect(user).to be_invalid
      expect(user.errors[:email]).to_not be_empty
    end

    it "shoud have accepted_terms" do
      user.current_sign_in_at = Time.now
      expect(user).to be_valid
      user.accept_terms = 'false'
      user.save!
      expect(user).to be_invalid
      expect(user.errors[:accept_terms]).to_not be_empty
    end
  end

  context "callbacks" do
    it "default profile_type should be set" do
      expect(user.profile_type).to be_nil
      user.save!
      expect(user.profile_type).to be_truthy
    end
  end

  describe 'public methods' do
    context 'responds to methods' do
      it { expect(user).to respond_to(:company_default_type) }
    end

    context '#company_default_type' do
      it 'returns company type for admin user' do
        admin_user = create(:admin_user)
        expect(admin_user.company_default_type).to eq(Company::COMPANY_TYPES.index(:admin))
      end

      it 'returns company type for tenant user' do
        tenant_user = create(:tenant_user)
        expect(tenant_user.company_default_type).to eq(Company::COMPANY_TYPES.index(:admin))
      end

      it 'returns reseller type for partner user' do
        partner_user = create(:partner_user)
        expect(partner_user.company_default_type).to eq(Company::COMPANY_TYPES.index(:partner))
      end

      it 'returns customer type for customer user' do
        customer_user = create(:customer_user)
        expect(customer_user.company_default_type).to eq(Company::COMPANY_TYPES.index(:customer))
      end
    end
  end

end
