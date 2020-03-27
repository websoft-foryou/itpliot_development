require 'rails_helper'

RSpec.describe HomesController, type: :controller do
  let(:customer_user){ create(:customer_user) }
  let(:partner_user){ create(:partner_user) }
  let(:tenant_user){ create(:tenant_user) }
  let(:admin_user){ create(:admin_user) }

  let(:customer_company){ build(:customer_company)}
  let(:reseller_company){ build(:reseller_company)}
  let(:location){ build(:location)}

  describe '#show' do
    context 'when logged as admin_user' do
      it 'redirects to step1 if user has not accepted terms' do
        sign_in admin_user
        get :show

        expect(response).to redirect_to step1_homes_path
      end

      it 'renders show if accepted terms' do
        admin_user.update_attributes!(accept_terms: true)
        sign_in admin_user
        get :show

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when logged as tenant_user' do
      it 'redirects to step1 if user has not accepted terms' do
        sign_in tenant_user
        get :show

        expect(response).to redirect_to step1_homes_path
      end

      it 'renders show if accepted terms' do
        tenant_user.update_attributes!(accept_terms: true)
        sign_in tenant_user
        get :show

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when logged as partner_user' do
      it 'redirects to step1 if user has not accepted terms' do
        sign_in partner_user
        get :show

        expect(response).to redirect_to step1_homes_path
      end

      it 'redirects to step2 if user has accepted terms and has no company assigned' do
        partner_user.update_attributes!(accept_terms: true)
        sign_in partner_user
        get :show

        expect(response).to redirect_to step2_homes_path
      end

      it 'renders show if partner accepted terms and has a company assigned' do
        partner_user.update_attributes!(accept_terms: true, current_sign_in_at: Time.now)
        partner_user.company_users.create(company_id: reseller_company)
        sign_in partner_user

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when logged as customer_user' do
      it 'redirects to step1 if user has not accepted terms' do
        sign_in customer_user
        get :show

        expect(response).to redirect_to step1_homes_path
      end

      it 'redirects to step2 if user has accepted terms' do
        customer_user.update_attributes!(accept_terms: true)
        sign_in customer_user
        get :show

        expect(response).to redirect_to step2_homes_path
      end

      it 'renders show if user already completed registration' do
        customer_user.update_attributes!(accept_terms: true, current_sign_in_at: Time.now - 10.minutes)
        customer_company = create(:customer_company, location: create(:location))
        customer_user.company_users.create(company_id: customer_company)
        sign_in customer_user

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when not logged' do
      it 'redirects to sign_in' do
        get :show

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#step2' do
    context 'when logged as admin_user' do
      it 'redirect to root' do
        admin_user.update_attributes!(accept_terms: true)
        sign_in admin_user
        get :step2

        expect(response).to redirect_to root_path
      end
    end

    context 'when logged as tenant_user' do
      it 'redirect to root' do
        tenant_user.update_attributes!(accept_terms: true)
        sign_in tenant_user
        get :step2

        expect(response).to redirect_to root_path
      end
    end

    context 'when logged as partner_user' do
      before do
        partner_user.update_attributes!(accept_terms: true)
        sign_in partner_user
        get :step2
      end
      it 'returns http success if user has no company' do
        expect(response).to have_http_status(:success)
      end

      it 'returns http success if user assigned to company' do
        partner_user.company_users.create(company_id: reseller_company)

        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged as customer_user' do
      before do
        customer_user.update_attributes!(accept_terms: true)
        sign_in customer_user
        get :step2
      end
      it 'returns http success if user has no company' do
        expect(response).to have_http_status(:success)
      end

      it 'returns http success if user assigned to company' do
        customer_user.company_users.create(company_id: customer_company)

        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged' do
      it 'redirects to sign_in' do
        get :step2

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#step2_create' do
    context 'when logged as admin_user' do
      before do
        admin_user.update_attributes!(accept_terms: true)
        sign_in admin_user
      end
      it 'redirects to root' do
        post :step2_create, params: {company: customer_company.attributes}

        expect(response).to redirect_to root_path
      end

      it 'fails to create company' do
        expect do
          post :step2_create, params: {company: customer_company.attributes}
        end.to_not(change { Company.count })
      end
    end

    context 'when logged as tenant_user' do
      before do
        tenant_user.update_attributes!(accept_terms: true)
        sign_in tenant_user
      end
      it 'redirects to root' do
        post :step2_create, params: {company: customer_company.attributes}

        expect(response).to redirect_to root_path
      end

      it 'fails to create company' do
        expect do
          post :step2_create, params: {company: customer_company.attributes}
        end.to_not(change { Company.count })
      end
    end

    context 'when logged as partner_user' do
      context 'when no company assigned' do
        before do
          partner_user.update_attributes!(accept_terms: true)
          sign_in partner_user
        end
        it 'redirects to partner_step3 on success' do
          post :step2_create, params: {company: customer_company.attributes}

          expect(response).to redirect_to partner_step3_homes_path
        end

        it 'creates company' do
          expect do
            post :step2_create, params: {company: customer_company.attributes}
          end.to change { Company.count }.by(1)
        end

        it 'associates created company to partner_user' do
          post :step2_create, params: {company: customer_company.attributes}
          
          expect(partner_user.companies.first).to_not be_nil
        end

        it 'changes to default reseller_company type' do
          post :step2_create, params: {company: customer_company.attributes}
          
          expect(partner_user.companies.first.is_reseller?).to be true
        end

        it 'adds default parent_id' do
          post :step2_create, params: {company: customer_company.attributes}
          
          expect(partner_user.companies.first.parent).to be Company.default_parent
        end

        it 'renders step2 on fail' do
          customer_company.name = ''
          post :step2_create, params: {company: customer_company.attributes}

          expect(response).to render_template('step2')
        end
      end

      context 'when already a company is assinged' do
        before do
          partner_user.update_attributes!(accept_terms: true)
          reseller_company = create(:reseller_company, :with_location)
          partner_user.company_users.create(company_id: reseller_company.id)
          sign_in partner_user
        end
        it 'should not create a company' do
          expect do
            post :step2_create, params: {company: customer_company.attributes}
          end.to_not change { Company.count }
        end

        it 'redirects to root' do
          post :step2_create, params: {company: customer_company.attributes}

          expect(response).to redirect_to root_path
        end
      end
    end

    context 'when logged as customer_user' do
      context 'when no company assigned' do
        before do
          customer_user.update_attributes!(accept_terms: true)
          sign_in customer_user
        end
        it 'redirects to step3 on success' do
          post :step2_create, params: {company: customer_company.attributes}

          expect(response).to redirect_to step3_homes_path
        end

        it 'creates company' do
          expect do
            post :step2_create, params: {company: customer_company.attributes}
          end.to change { Company.count }.by(1)
        end

        it 'associates created company to customer_user' do
          post :step2_create, params: {company: customer_company.attributes}
          
          expect(customer_user.companies.first).to_not be_nil
        end

        it 'changes to default customer_company type' do
          post :step2_create, params: {company: reseller_company.attributes}
          
          expect(customer_user.companies.first.is_customer?).to be true
        end

        it 'adds default parent_id' do
          post :step2_create, params: {company: customer_company.attributes}
          
          expect(customer_user.companies.first.parent).to be Company.default_parent
        end

        it 'renders step2 on fail' do
          customer_company.name = ''
          post :step2_create, params: {company: customer_company.attributes}

          expect(response).to render_template('step2')
        end
      end

      context 'when already a company is assinged' do
        before do
          customer_user.update_attributes!(accept_terms: true)
          customer_company = create(:customer_company, :with_location)
          customer_user.company_users.create(company_id: customer_company.id)
          sign_in customer_user
        end
        it 'should not create a company' do
          expect do
            post :step2_create, params: {company: customer_company.attributes}
          end.to_not change { Company.count }
        end

        it 'redirects to root' do
          post :step2_create, params: {company: customer_company.attributes}

          expect(response).to redirect_to root_path
        end
      end
    end

    context 'when not logged' do
      it 'redirects to sign_in' do
        post :step2_create, params: {company: customer_company.attributes}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#step3' do
    context 'when logged as admin_user' do
      it 'redirects to root' do
        admin_user.update_attributes!(accept_terms: true)
        sign_in admin_user
        get :step3

        expect(response).to redirect_to root_path
      end
    end

    context 'when logged as tenant_user' do
      it 'redirects to root' do
        tenant_user.update_attributes!(accept_terms: true)
        sign_in tenant_user
        get :step3

        expect(response).to redirect_to root_path
      end
    end

    context 'when logged as partner_user' do
      before do
        partner_user.update_attributes!(accept_terms: true)
        sign_in partner_user
      end
      it 'returns http success' do
        company = create(:reseller_company)
        partner_user.company_users.create(company_id: company.id)
        get :step3

        expect(response).to have_http_status(:success)
      end

      it 'redirects home if no company assigned' do
        get :step3

        expect(response).to redirect_to root_path
      end
    end

    context 'when logged as customer_user' do
      before do
        customer_user.update_attributes!(accept_terms: true)
        sign_in customer_user
      end
      it 'returns http success' do
        company = create(:customer_company)
        customer_user.company_users.create(company_id: company.id)
        get :step3

        expect(response).to have_http_status(:success)
      end

      it 'redirects home if no company assigned' do
        get :step3

        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#partner_step3' do
    context 'when logged as admin_user' do
      it 'redirects to root' do
        admin_user.update_attributes!(accept_terms: true)
        sign_in admin_user
        get :partner_step3

        expect(response).to redirect_to root_path
      end
    end

    context 'when logged as tenant_user' do
      it 'redirects to root' do
        tenant_user.update_attributes!(accept_terms: true)
        sign_in tenant_user
        get :partner_step3

        expect(response).to redirect_to root_path
      end
    end

    context 'when logged as partner_user' do
      before do
        partner_user.update_attributes!(accept_terms: true)
        sign_in partner_user
      end
      it 'returns http success' do
        company = create(:reseller_company)
        partner_user.company_users.create(company_id: company.id)
        get :partner_step3

        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged as customer_user' do
      it 'redirects to root' do
        customer_user.update_attributes!(accept_terms: true)
        sign_in customer_user
        get :partner_step3

        expect(response).to redirect_to root_path
      end
    end
  end
end
