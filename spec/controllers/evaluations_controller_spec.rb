require 'rails_helper'

RSpec.describe EvaluationsController, type: :controller do
  let(:admin_user){ create(:admin_user, :accepted_terms) }
  let(:tenant_user){ create(:tenant_user, :accepted_terms) }
  let(:partner_user){ create(:partner_user, :accepted_terms) }

  let(:customer_user){ create(:customer_user, :accepted_terms) }
  let(:current_company){ create(:company_company) }
  let(:current_customer){ create(:customer_company, parent_id: current_company.id) }
  let(:reseller_company){ create(:reseller_company, parent_id: current_company.id) }
  let(:evaluation){ create(:evaluation, customer_id: current_customer.id, company_id: current_company.id) }

  let!(:s1){ create(:service) }
  let!(:s2){ create(:service) }

  describe '#index' do
    context 'when logged in' do
      it 'returns http success for admin user' do
        sign_in admin_user
        get :index, params: {customer_id: current_customer.id}

        expect(response).to have_http_status(:success)
      end

      it 'returns http success for customer user' do
        customer_user.company_users.create(company_id: current_customer.id)
        sign_in customer_user
        get :index, params: {customer_id: current_customer.id}

        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged without access to company' do
      it 'returns raise error for customer' do
        sign_in customer_user

        expect {
          get :index, params: {customer_id: current_customer.id}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :index, params: {customer_id: current_customer.id}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#new' do
    context 'when logged in' do
      context 'when customer has no location' do
        it 'redirects admin to the customer page' do
          sign_in admin_user
          get :new, params: {customer_id: current_customer.id}

          expect(response).to redirect_to customer_path(current_customer.id)
          expect(flash[:alert]).to eq  I18n.t("evaluation_results.add_at_least_one_location")
        end

        it 'redirects partner to customer page' do
          sign_in partner_user
          partner_user.company_users.create(company_id: reseller_company.id)
          current_customer.update_attributes!(parent_id: reseller_company.id)
          get :new, params: {customer_id: current_customer.id}

          expect(response).to redirect_to customer_path(current_customer.id)
          expect(flash[:alert]).to eq  I18n.t("evaluation_results.add_at_least_one_location")
        end

        it 'redirects customer to the customer page' do
          sign_in customer_user
          customer_user.company_users.create(company_id: current_customer.id)
          get :new, params: {customer_id: current_customer.id}

          expect(response).to redirect_to customer_path(current_customer.id)
          expect(flash[:alert]).to eq  I18n.t("evaluation_results.add_at_least_one_location")
        end
      end

      context 'when customer has a location' do
        before do
          create(:company_branch, company_id: current_customer.id)
        end
        it 'returns http success for admin user' do
          sign_in admin_user
          get :new, params: {customer_id: current_customer.id}

          expect(response).to have_http_status(:success)
        end

        it 'returns http success for partner user' do
          sign_in partner_user
          partner_user.company_users.create(company_id: reseller_company.id)
          current_customer.update_attributes!(parent_id: reseller_company.id)
          get :new, params: {customer_id: current_customer.id}

          expect(response).to have_http_status(:success)
        end

        it 'returns http success for customer user' do
          customer_user.company_users.create(company_id: current_customer.id)
          sign_in customer_user
          get :new, params: {customer_id: current_customer.id}

          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'when logged without access to company' do
      it 'returns raise error for customer' do
        sign_in customer_user

        expect {
          get :new, params: {customer_id: current_customer.id}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :new, params: {customer_id: current_customer.id}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#dashboard' do
    context 'when not logged in' do
      it 'redirects to the login page' do
        get :dashboard, params: {customer_id: current_customer.id, id: evaluation.id}

        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when logged in' do
      context 'when evaluation has draft evaluation services' do
        it 'restricts access' do
          customer_user.company_users.create(company_id: current_customer.id)
          sign_in customer_user
          get :dashboard, params: {customer_id: current_customer.id, id: evaluation.id}

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to customer_evaluation_path(current_customer.id, evaluation)
        end
      end

      context 'when evaluation has all evaluation services active/ignored' do
        it 'returns http success' do
          evaluation.evaluation_services.update_all(status: 0)
          sign_in admin_user
          get :dashboard, params: {customer_id: current_customer.id, id: evaluation.id}
          expect(response).to have_http_status(:success)

          sign_in customer_user
          get :dashboard, params: {customer_id: current_customer.id, id: evaluation.id}
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe '#create' do
    context 'when logged as admin_user' do
      it 'should redirect to show on success' do
        sign_in admin_user
        expect do
          post :create, params: {evaluation: {name: 'New Assessment'}, customer_id: current_customer.id}
        end.to change { Evaluation.count }.by(1)
        created_evaluation = Evaluation.order(:id).last
        expect(response).to redirect_to(customer_evaluation_path(current_customer, created_evaluation.id))
      end

      it 'should render new on failure' do
        sign_in admin_user
        expect do
          post :create, params: {evaluation: {name: ''}, customer_id: current_customer.id}
        end.to change { Evaluation.count }.by(0)
        expect(response).to render_template('new')
      end
    end

    context 'when logged as customer' do
      it 'should create and redirect to show on success' do
        customer_user.company_users.create(company_id: current_customer.id)
        sign_in customer_user
        expect do
          post :create, params: {evaluation: {name: 'New Assessment'}, customer_id: current_customer.id}
        end.to change { Evaluation.count }.by(1)
        expect(response).to redirect_to(customer_evaluation_path(current_customer, Evaluation.order(:id).last))
      end
    end

    context 'for customer with premium account' do
      before do
        sign_in customer_user
        customer_user.company_users.create(company_id: current_customer.id)
        current_customer.update_attributes!(premium_from: Time.now() - 1.day, premium_until: Time.now() + 1.day)
      end

      it 'should fail if a draft evaluation exists' do
        expect(current_customer.premium?).to be true
        expect(evaluation.status).to eq(0)

        expect do
          post :create, params: {evaluation: {name: 'Second Assessment'}, customer_id: current_customer.id}
        end.to change { Evaluation.count }.by(0)
      end

      it 'should be successfull if all evaluations are published' do
        expect(current_customer.premium?).to be true
        evaluation.status = 1
        evaluation.save

        expect do
          post :create, params: {evaluation: {name: 'Second Assessment'}, customer_id: current_customer.id}
        end.to change { Evaluation.count }.by(1)
      end
    end

    context 'for customer without premium account' do
      before do
        sign_in customer_user
        customer_user.company_users.create(company_id: current_customer.id)
      end

      it 'should fail for a second evaluation if first is draft' do
        expect(current_customer.premium?).to be false
        expect(evaluation.status).to eq(0)

        expect do
          post :create, params: {evaluation: {name: 'Second Assessment'}, customer_id: current_customer.id}
        end.to change { Evaluation.count }.by(0)
      end

      it 'should fail for a second evaluation if first is published' do
        expect(current_customer.premium?).to be false
        evaluation.status = 1

        expect do
          post :create, params: {evaluation: {name: 'Second Assessment'}, customer_id: current_customer.id}
        end.to change { Evaluation.count }.by(0)
      end
    end
  end

  describe '#change_mass' do
    before do
      sign_in customer_user
      customer_user.company_users.create(company_id: current_customer.id)
      evaluation.evaluation_services.update_all(status: 0)
    end

    it 'should redirect with no results if no selected services' do
      post :change_mass, params: {selected_service_ids: nil, filters: {"order"=>"position"}, status: 'active', id: evaluation, customer_id: current_customer}
      expect(response).to redirect_to(customer_evaluation_path(current_customer, evaluation, order: 'position'))
      expect(subject.request.flash[:notice]).to eq I18n.t('evaluations.no_services_selected')
      expect(evaluation.evaluation_results.count).to eq 0
    end

    it 'should redirect with no results if no branch assigned' do
      post :change_mass, params: {selected_service_ids: evaluation.evaluation_services.pluck(:service_id), filters: {"order"=>"position"}, status: 'active', id: evaluation, customer_id: current_customer}
      expect(response).to redirect_to(customer_evaluation_path(current_customer, evaluation, order: 'position'))
      expect(subject.request.flash[:notice]).to eq I18n.t('evaluation_results.add_and_select_at_least_one_location')
      expect(evaluation.evaluation_results.count).to eq 0
    end

    it 'should create results' do
      company_branch = create(:company_branch, company_id: current_customer.id)
      expect(current_customer.company_branches.first).to_not be_nil
      post :change_mass, params: {selected_service_ids: evaluation.evaluation_services.pluck(:service_id), filters: {"order"=>"position"}, status: 'active', id: evaluation, customer_id: current_customer}
      expect(subject.request.flash[:notice]).to be_nil
      expect(evaluation.evaluation_results.count).to eq (evaluation.evaluation_services.count)
    end

  end

  # describe '#publish' do
  #   before do
  #     sign_in customer_user
  #     customer_user.company_users.create(company_id: current_customer.id)
  #     company_branch = create(:company_branch, company_id: current_customer.id)
  #     evaluation.evaluation_services.update_all(status: 0)
  #   end

  #   it 'should publish evaluation' do
  #     current_customer.update_attributes!(premium_from: Time.now() - 1.day, premium_until: Time.now() + 1.day)
  #     post :change_mass, params: {selected_service_ids: evaluation.evaluation_services.pluck(:service_id), filters: {"order"=>"position"}, status: 'active', id: evaluation, customer_id: current_customer}

  #     expect do
  #         get :publish, params: {customer_id: current_customer, id: evaluation}
  #     end.to change { evaluation.status }
  #   end
  # end

  describe '#edit' do
    context 'when logged in' do
      context 'with right access credentials' do
        it 'returns http success for admin' do
          sign_in admin_user
          get :edit, params: {customer_id: current_customer.id, id: evaluation.id}

          expect(response).to have_http_status(:success)
        end

        it 'returns http success for customer' do
          customer_user.company_users.create(company_id: current_customer.id)
          sign_in customer_user
          get :edit, params: {customer_id: current_customer.id, id: evaluation.id}

          expect(response).to have_http_status(:success)
        end
      end

      context 'without access rights' do
        it 'raises error' do
          sign_in customer_user

          expect {
            get :edit, params: {customer_id: current_customer.id, id: evaluation.id}
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :edit, params: {customer_id: current_customer.id, id: evaluation.id}

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe '#show' do
    context 'when logged in' do
      context 'with right access credentials' do
        it 'returns http success for admin' do
          sign_in admin_user
          get :show, params: {customer_id: current_customer.id, id: evaluation.id}

          expect(response).to have_http_status(:success)
        end

        it 'returns http success for customer' do
          customer_user.company_users.create(company_id: current_customer.id)
          sign_in customer_user
          get :show, params: {customer_id: current_customer.id, id: evaluation.id}

          expect(response).to have_http_status(:success)
        end
      end

      context 'without access rights' do
        it 'raises error' do
          sign_in customer_user

          expect {
            get :show, params: {customer_id: current_customer.id, id: evaluation.id}
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'when not logged in' do
      it 'redirects to the login page' do
        get :show, params: {customer_id: current_customer.id, id: evaluation.id}

        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when add a new global service' do
      it 'should add draft services to a draft evaluation' do
        expect(evaluation.evaluation_services.count).to eq(2)
        create(:service)
        sign_in admin_user
        get :show, params: {customer_id: current_customer.id, id: evaluation.id}
        expect(evaluation.evaluation_services.count).to eq(3)
      end

      it 'should not add draft services to a published evaluation' do
        expect(evaluation.evaluation_services.count).to eq(2)
        evaluation.update_attributes!(status: 1)
        create(:service)
        sign_in admin_user
        get :show, params: {customer_id: current_customer.id, id: evaluation.id}
        expect(evaluation.evaluation_services.count).to eq(2)
      end
    end
  end

  describe '#update' do
    before do
      customer_user.company_users.create(company_id: current_customer.id)
    end
    it 'should successfully update and redirect with message' do
      sign_in customer_user
      put :update, params: {customer_id: current_customer.id, id: evaluation.id, evaluation: { name: 'new name'}}

      expect(response).to redirect_to(customer_evaluation_path(current_customer, evaluation))
      expect(flash[:notice]).to eq I18n.t('evaluations.messages.successfully_updated')
    end

    it 'should fail if not logged' do
      put :update, params: {customer_id: current_customer.id, id: evaluation.id, evaluation: { name: 'new name'}}

      expect(response).to redirect_to new_user_session_path
    end
  end

  describe '#destroy' do
    before do
      customer_user.company_users.create(company_id: current_customer.id)
    end
    it "should destroy evaluation" do
      sign_in customer_user
      delete :destroy, params: {customer_id: current_customer.id, id: evaluation.id}

      expect(Evaluation.count).to eq(0)
      expect(response).to redirect_to customer_evaluations_path(current_customer)
    end

    it "should fail if user has not the right credentials" do
      another_user = create(:customer_user, :accepted_terms)
      sign_in (another_user)

      expect {
        delete :destroy, params: {customer_id: current_customer.id, id: evaluation.id}
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Evaluation.count).to eq(1)
    end

    it "should fail if not logged" do
      customer_user.company_users.create(company_id: current_customer.id)
      delete :destroy, params: {customer_id: current_customer.id, id: evaluation.id}

      expect(response).to redirect_to new_user_session_path
      expect(Evaluation.count).to eq(1)
    end
  end
end
