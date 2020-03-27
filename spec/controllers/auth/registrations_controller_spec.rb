require 'rails_helper'

# - redirect unlogged user to sign_in
# - redirect admin user to dashboard after sign_in
# - redirect customer user to step1 after sign_in

# - TODO: update user params

RSpec.describe Auth::RegistrationsController, :type => :controller do
  let(:admin_user) { create(:admin_user) }
  let(:customer_user) { create(:customer_user) }
  let(:accept_admin_user) { create(:admin_user, :accepted_terms) }
  let(:accept_customer_user) { create(:customer_user, :accepted_terms) }

  describe 'sign_in user' do
    context "without accepted terms" do
      it "redirects admin user to step1 page" do
        login(admin_user)
        expect(current_path).to eq(step1_homes_path)
      end

      it "redirects customer user to step1 page" do
        login(customer_user)
        expect(current_path).to eq(step1_homes_path)
      end
    end

    context "with accepted terms" do
      it "redirects admin user to dashboard page" do
        login(accept_admin_user)
        expect(current_path).to eq(root_path)
      end

      it "redirects customer user to step2 page" do
        login(accept_customer_user)
        expect(current_path).to eq(step2_homes_path)
      end
    end

    context "as guest" do
      it "redirects to sign_in" do
        visit root_path
        expect(current_path).to eq(new_user_session_path)
      end
    end
  end

  describe '#edit' do
    context "authenticated user" do
      it "renders edit template" do
        login(customer_user)
        visit edit_user_registration_path
        expect(response).to have_http_status "200"
      end
    end
    context 'as guest' do
      it "redirects to sign_in" do
        visit edit_user_registration_path
        expect(current_path).to eq(new_user_session_path)
      end
    end
  end

end
