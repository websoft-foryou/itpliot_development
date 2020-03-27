require 'rails_helper'

# - accessed only by admins

RSpec.describe CompanyUsersController, type: :controller do
  let(:admin_user){ create(:admin_user) }
  let(:tenant_user){ create(:tenant_user) }
  let(:customer_user){ create(:customer_user) }
  let(:company_company){ create(:company_company) }


  describe '#create' do
    context 'when logged as admin_user' do
      it 'should successfully create association with right credentials and redirect to show company' do
        sign_in admin_user
        request.env["HTTP_REFERER"] = company_path(company_company)
        expect do
          post :create, params: {company_user: {user_id: tenant_user.id}, company_id: company_company.id}
        end.to change { CompanyUser.count }.by(1)

        expect(response).to redirect_to company_path(company_company)
      end

      it 'shouldnt create association and responds with error if no user_id provided' do
        sign_in admin_user
        expect do
          post :create, params: {company_user: {user_id: ''}, company_id: company_company.id}
        end.to_not change{CompanyUser.count}

        expect(response).to redirect_to company_path(company_company)
      end
    end

    context 'when logged as tenant/customer' do
      it 'should not create company_user association by tenant' do
        sign_in tenant_user
        request.env["HTTP_REFERER"] = company_path(company_company)

        expect do
          post :create, params: {company_user: {user_id: ''}, company_id: company_company.id}
        end.to_not change{CompanyUser.count}
      end

      it 'should not create company_user association by customer' do
        sign_in customer_user
        request.env["HTTP_REFERER"] = company_path(company_company)

        expect do
          post :create, params: {company_user: {user_id: ''}, company_id: company_company.id}
        end.to_not change{CompanyUser.count}
      end
    end
  end


  describe '#destroy' do
    context 'when logged as admin user' do
      it 'should destroy association' do
        sign_in admin_user
        request.env["HTTP_REFERER"] = company_path(company_company)
        company_user = create(:company_user)

        expect do
            delete :destroy, params: {id: company_user, company_id: company_user.company_id}
          end.to change { CompanyUser.count }.by(-1)
      end
    end
    context 'when logged as tenant/customer' do
      it 'tenant should not sucessfully delete' do
        sign_in tenant_user
        request.env["HTTP_REFERER"] = company_path(company_company)
        company_user = create(:company_user)

        expect do
            delete :destroy, params: {id: company_user, company_id: company_user.company_id}
          end.to_not change { CompanyUser.count }
      end

      it 'customer should not sucessfully delete' do
        sign_in customer_user
        request.env["HTTP_REFERER"] = company_path(company_company)
        company_user = create(:company_user)

        expect do
            delete :destroy, params: {id: company_user, company_id: company_user.company_id}
          end.to_not change { CompanyUser.count }
      end
    end
  end
end
