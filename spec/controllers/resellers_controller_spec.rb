require 'rails_helper'

RSpec.describe ResellersController, type: :controller do
  let(:business){ create(:business) }
  let(:company_company){ create(:company_company) }
  let(:reseller_company){ create(:reseller_company, :with_location, parent_id: company_company.id) }

  let(:admin_user){ create(:admin_user) }
  let(:tenant_user){ create(:tenant_user) }
  let(:partner_user){ create(:partner_user) }
  let(:customer_user){ create(:customer_user) }

  describe '#index' do
    context 'when logged as admin' do
      it 'returns http success' do
        sign_in admin_user
        get :index, params: {company_id: company_company.id}

        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged as tenant of company_company' do
      it 'returns http success' do
        sign_in tenant_user
        tenant_user.company_users.create(company_id: company_company.id)
        get :index, params: {company_id: company_company.id}

        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :index, params: {company_id: reseller_company.id}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#new' do
    context 'when logged as admin' do
      it 'returns http success' do
        sign_in admin_user
        get :new, params: {company_id: company_company.id}

        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged as tenant of company_company' do
      it 'returns http success' do
        sign_in tenant_user
        tenant_user.company_users.create(company_id: company_company.id)
        get :new, params: {company_id: company_company.id}

        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :new, params: {company_id: company_company.id}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#show' do
    context 'when logged as admin' do
      it 'returns http success' do
        sign_in admin_user
        get :show, params: {company_id: company_company, id: reseller_company}

        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged as tenant of company_company' do
      it 'returns http success' do
        sign_in tenant_user
        tenant_user.company_users.create(company_id: company_company.id)
        get :show, params: {company_id: company_company, id: reseller_company}

        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged as partner of reseller_company' do
      it 'returns http success' do
        sign_in partner_user
        partner_user.company_users.create(company_id: reseller_company.id)
        get :show, params: {company_id: company_company, id: reseller_company}

        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :show, params: {company_id: company_company, id: reseller_company}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # describe '#create' do
  # end

  describe '#update' do
    context 'when logged as admin' do
      before do
        sign_in admin_user
      end
      it 'redirects to show on success' do
        put :update, params: { company: {name: 'NewName'}, company_id: company_company, id: reseller_company }

        expect(response).to redirect_to company_reseller_path(company_company, reseller_company)
      end

      it 'renders edit on error' do
        put :update, params: { company: {name: ''}, company_id: company_company, id: reseller_company }

        expect(response).to render_template('edit')
      end
    end

    context 'when tenant of company_company' do
      before do
        sign_in tenant_user
        tenant_user.company_users.create(company_id: company_company.id)
      end
      it 'redirects to show on success' do
        put :update, params: { company: {name: 'NewName'}, company_id: company_company, id: reseller_company }

        expect(response).to redirect_to company_reseller_path(company_company, reseller_company)
      end

      it 'renders edit on error' do
        put :update, params: { company: {name: ''}, company_id: company_company, id: reseller_company }

        expect(response).to render_template('edit')
      end

      it 'should permit is_blocked change' do
        put :update, params: { company: {is_blocked: true}, company_id: company_company, id: reseller_company }
        reseller_company.reload

        expect(reseller_company.is_blocked).to be true
      end
    end

    context 'when partner of reseller company' do
      before do
        sign_in partner_user
        partner_user.company_users.create(company_id: reseller_company.id)
      end
      it 'redirects to show on success' do
        put :update, params: { company: {name: 'NewName'}, company_id: company_company, id: reseller_company }

        expect(response).to redirect_to company_reseller_path(company_company, reseller_company)
      end

      it 'responds with success notice' do
        put :update, params: { company: {name: 'NewName'}, company_id: company_company, id: reseller_company }

        expect(flash[:notice]).to eq I18n.t('partners.messages.successfully_updated')
      end

      it 'renders edit on error' do
        put :update, params: { company: {name: ''}, company_id: company_company, id: reseller_company }

        expect(response).to render_template('edit')
      end

      it 'without subscription' do
        put :update, params: { company: {name: 'NewName', premium_from: Time.now, premium_until: Time.now + 1.day}, company_id: company_company, id: reseller_company }

        reseller_company.reload
        expect(reseller_company.name).to eq 'NewName'
        expect(reseller_company.premium_from).to be_nil
        expect(reseller_company.premium_until).to be_nil
      end

      it 'should not permit is_blocked change' do
        put :update, params: { company: {is_blocked: true}, company_id: company_company, id: reseller_company }
        reseller_company.reload

        expect(reseller_company.is_blocked).to be false
      end
    end
  end

  describe '#destroy' do
    context 'when logged as admin' do
      before do
        sign_in admin_user
      end
      it 'redirects to resellers list for default company' do
        reseller = create(:reseller_company, :with_location, parent_id: company_company.id)
        delete :destroy, params: {company_id: company_company, id: reseller}

        expect(response).to redirect_to company_resellers_path(company_company)
      end

      it 'deletes reseller on success' do
        reseller = create(:reseller_company, :with_location, parent_id: company_company.id)
        expect do
          delete :destroy, params: {company_id: company_company, id: reseller}
        end.to change { Company.reseller.count }.by(-1)
      end
    end

    context 'when logged as tenant' do
      before do
        sign_in tenant_user
      end
      it 'deletes reseller on success' do
        reseller = create(:reseller_company, :with_location, parent_id: company_company.id)
        tenant_user.company_users.create(company_id: company_company.id)
        expect do
          delete :destroy, params: {company_id: company_company, id: reseller}
        end.to change { Company.reseller.count }.by(-1)
      end

      it 'raises error if not in tenant scope' do
        reseller = create(:reseller_company, :with_location, parent_id: company_company.id)
        another_company = create(:company_company)
        tenant_user.company_users.create(company_id: another_company.id)
        expect do
          delete :destroy, params: {company_id: company_company, id: reseller}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when logged as partner' do
      before do
        sign_in partner_user
      end
      it 'does not delete reseller' do
        reseller = create(:reseller_company, :with_location, parent_id: company_company.id)
        partner_user.company_users.create(company_id: reseller.id)
        expect do
          delete :destroy, params: {company_id: company_company, id: reseller}
        end.to_not(change { Company.reseller.count })
      end
    end

  end


end
