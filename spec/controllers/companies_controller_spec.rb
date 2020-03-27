require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:business){ create(:business) }
  let(:company_company){ create(:company_company) }
  let(:admin_user){ create(:admin_user) }

  let(:tenant_user){ create(:tenant_user) }
  let(:partner_user){ create(:partner_user) }
  let(:customer_user){ create(:customer_user) }

  describe '#index' do
    context 'when logged as admin' do
      it 'returns http success' do
        sign_in admin_user
        get :index

        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged as admin' do
      it 'redirect to root for customer user' do
        sign_in customer_user
        get :index

        expect(response).to redirect_to root_path
      end

      it 'redirects to root for partner user' do
        sign_in partner_user
        get :index

        expect(response).to redirect_to root_path
      end

      it 'redirects to root for tenant user' do
        sign_in tenant_user
        get :index

        expect(response).to redirect_to root_path
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :index

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#new' do
    context 'when logged as admin' do
      it 'returns http success' do
        sign_in admin_user
        get :new

        expect(response).to have_http_status(:success)
      end
    end

    context 'when not logged as admin' do
      it 'redirects to root customer user' do
        sign_in customer_user
        get :new

        expect(response).to redirect_to root_path
      end

      it 'redirects to root partner user' do
        sign_in partner_user
        get :new

        expect(response).to redirect_to root_path
      end

      it 'redirects to root tenant user' do
        sign_in tenant_user
        get :new

        expect(response).to redirect_to root_path
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :new

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#show' do
    context 'when logged as admin' do
      it 'shows company' do
        sign_in admin_user
        get :show, params: {id: company_company}

        expect(response).to render_template('show')
      end
    end

    context 'when not logged as admin' do
      it 'redirects to root customer user' do
        sign_in customer_user
        get :show, params: {id: company_company}

        expect(response).to redirect_to root_path
      end

      it 'redirects to root parnter user' do
        sign_in partner_user
        get :show, params: {id: company_company}

        expect(response).to redirect_to root_path
      end

      it 'redirects to root tenant user' do
        sign_in tenant_user
        get :show, params: {id: company_company}

        expect(response).to redirect_to root_path
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :show, params: {id: company_company}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#create' do
    context 'when logged as admin' do
      before do
        sign_in admin_user
        @company_params = {name: 'Company name',
                         contact_person: 'C.P.',
                         phone: '1234567890',
                         mobile: '1234567890',
                         email: 'office@company.com',
                         vat_number: 'VAT',
                         business_id: business.id}
      end

      it 'it should successfully create new company and render show' do
        expect do
          post :create, params: {company: @company_params}
        end.to change { Company.count }.by(1)
      end

      it 'it should render show' do
        post :create, params: {company: @company_params}

        expect(response).to render_template('show')
      end

      it 'it shoud have type:company' do
        post :create, params: {company: @company_params}

        company = Company.order(:id).last
        expect(company.company_type_name).to eq(:admin)
      end
    end

    context 'when not logged as admin' do
      before do
        @company_params = {name: 'Company name',
                         contact_person: 'C.P.',
                         phone: '1234567890',
                         mobile: '1234567890',
                         email: 'office@company.com',
                         vat_number: 'VAT',
                         business_id: business.id}
      end
      it 'should not create company as customer user' do
        sign_in customer_user

        expect do
          post :create, params: {company: @company_params}
        end.to change { Company.count }.by(0)
      end

      it 'should not create company as partner user' do
        sign_in partner_user

        expect do
          post :create, params: {company: @company_params}
        end.to change { Company.count }.by(0)
      end

      it 'should not create company as tenant user' do
        sign_in tenant_user

        expect do
          post :create, params: {company: @company_params}
        end.to change { Company.count }.by(0)
      end

      it 'should redirect to root a customer user' do
        sign_in customer_user
        post :create, params: {company: @company_params}

        expect(response).to redirect_to root_path
      end

      it 'should redirect to root a partner user' do
        sign_in partner_user
        post :create, params: {company: @company_params}

        expect(response).to redirect_to root_path
      end

      it 'should redirect to root a tenant user' do
        sign_in tenant_user
        post :create, params: {company: @company_params}

        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#update' do
    context 'when logged as admin' do
      context 'when successfully update' do
        it 'redirects to the show on success' do
          sign_in admin_user
          company = create(:company_company)
          put :update, params: { company: {name: 'Company new name'}, id: company.id }

          expect(response).to redirect_to company_path(company.id)
        end

        it 'redirects to the edit on error' do
          sign_in admin_user
          company = create(:company_company)
          put :update, params: {company: {name: ''}, id: company.id}

          expect(response).to render_template('edit')
        end
      end

      context 'when try to update unpermitted params' do
        it 'does not change company type' do
          sign_in admin_user
          company = create(:company_company)
          put :update, params: {company: {company_type: Company::COMPANY_TYPES.index(:customer)}, id: company.id}

          expect(company.company_type_name).to eq(:admin)
        end

        it 'does not change parent_id' do
          sign_in admin_user
          company = create(:company_company)
          put :update, params: {company: {parent_id: 1}, id: company.id}

          expect(company.parent_id).to be_nil
        end
      end
    end

    context 'when not logged as admin' do
      it 'is not permitted for customer user' do
        sign_in customer_user
        put :update, params: { company: {name: 'New name'}, id: company_company }

        expect(company_company.name).to_not eq('New name')
      end

      it 'is not permitted for partner user' do
        sign_in partner_user
        put :update, params: { company: {name: 'New name'}, id: company_company }

        expect(company_company.name).to_not eq('New name')
      end

      it 'is not permitted for tenant user' do
        sign_in tenant_user
        put :update, params: { company: {name: 'New name'}, id: company_company }

        expect(company_company.name).to_not eq('New name')
      end

      it 'is redirected if customer user' do
        sign_in customer_user
        put :update, params: { company: {name: 'New name'}, id: company_company }

        expect(response).to redirect_to root_path
      end

      it 'is redirected if partner user' do
        sign_in partner_user
        put :update, params: { company: {name: 'New name'}, id: company_company }

        expect(response).to redirect_to root_path
      end

      it 'is redirected if tenant user' do
        sign_in tenant_user
        put :update, params: { company: {name: 'New name'}, id: company_company }

        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do
    context 'when logged as admin' do
      it 'destroys and redirect to index' do
        sign_in admin_user
        company = create(:company_company)

        expect do
            delete :destroy, params: {id: company}
          end.to change { Company.company.count }.by(-1)
        expect(response).to redirect_to companies_path
      end
    end

    context 'when not logged as admin' do
      it 'cannot destroy as customer' do
        sign_in customer_user
        company = create(:company_company)

        expect do
            delete :destroy, params: {id: company}
          end.to_not change { Company.company.count }
        expect(response).to redirect_to root_path
      end

      it 'cannot destroy as partner' do
        sign_in partner_user
        company = create(:company_company)

        expect do
            delete :destroy, params: {id: company}
          end.to_not change { Company.company.count }
        expect(response).to redirect_to root_path
      end

      it 'cannot destroy as tenant' do
        sign_in tenant_user
        company = create(:company_company)

        expect do
            delete :destroy, params: {id: company}
          end.to_not change { Company.company.count }
        expect(response).to redirect_to root_path
      end
    end
  end


end
