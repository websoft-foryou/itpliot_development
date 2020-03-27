require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  let(:admin_user){ create(:admin_user, :accepted_terms) }
  let(:tenant_user){ create(:tenant_user, :accepted_terms) }
  let(:partner_user){ create(:partner_user, :accepted_terms) }
  let(:customer_user){ create(:customer_user, :accepted_terms) }

  let(:company_company){ create(:company_company, :with_location) }
  let(:reseller_company){ create(:reseller_company, :with_location, parent_id: company_company.id) }
  let(:customer_company){ create(:customer_company, :with_location, parent_id: reseller_company.id) }

  let(:branch){ create(:company_branch, company_id: customer_company.id) }

  describe '#invite' do
    context 'by admin user' do
      context 'without email option' do
        before do
          sign_in admin_user
          company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
          @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', company_users_attributes: { '0' => company_users_params} }
          post :invite, params: {user: @invited_user_params}
        end
        it 'redirects to customer path' do
          expect(response).to redirect_to members_path
        end

        it 'creates user' do
          invited_user = User.last

          expect(invited_user.email).to eq(@invited_user_params[:email])
        end

        it 'should be a customer user' do
          invited_user = User.last

          expect(invited_user.profile_type_name).to eq(:customer)
        end

        it 'should be an registered user' do
          invited_user = User.last

          expect(invited_user.company_users.count).to eq 1
        end

        it 'should be registered with customer company' do
          invited_user = User.last

          expect(invited_user.company_users.first.company_id).to eq customer_company.id
        end

        it 'should be registered on branch company' do
          invited_user = User.last

          expect(invited_user.company_users.first.company_branch_id).to eq branch.id
        end

        it 'should register invited by info' do
          invited_user = User.last

          expect(invited_user.invited_by_id).to eq(admin_user.id)
        end

        it 'should send email' do
          last_email = ActionMailer::Base.deliveries.last

          expect(last_email).to be nil
        end

        it 'should register send email' do
          invited_user = User.last

          expect(invited_user.sent_email).to be false
        end
      end

      context 'with send email option' do
        before do
          sign_in admin_user
          company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
          @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', company_users_attributes: { '0' => company_users_params} }
          post :invite, params: {user: @invited_user_params, send_email: true}
        end
        it 'should send email' do
          last_email = ActionMailer::Base.deliveries.last

          expect(last_email.to).to eq [@invited_user_params[:email]]
        end

        it 'should register send email' do
          invited_user = User.last

          expect(invited_user.sent_email).to be true
        end
      end
    end

    context 'by tenant user' do
      context 'with fixed add to option' do
        context 'when invitor has rights on company' do
          before do
            tenant_user.company_users.create(company_id: company_company.id)
            customer_company.update_attributes!(parent_id: company_company.id)

            sign_in tenant_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params, addto: 1,customer_id: customer_company}
          end
          it 'creates user' do
            invited_user = User.last

            expect(invited_user.email).to eq(@invited_user_params[:email])
          end

          it 'should be a customer user' do
            invited_user = User.last

            expect(invited_user.profile_type_name).to eq(:customer)
          end

          it 'should be a registered user' do
            invited_user = User.last

            expect(invited_user.company_users.count).to eq 1
          end

          it 'should be registered with customer_company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_id).to eq customer_company.id
          end

          it 'should be registered on branch company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_branch_id).to eq branch.id
          end

          it 'redirects to members path' do
            expect(response).to redirect_to members_path
          end

          it 'should register invited by info' do
            invited_user = User.last

            expect(invited_user.invited_by_id).to eq(tenant_user.id)
          end

          it 'should send email' do
            last_email = ActionMailer::Base.deliveries.last

            expect(last_email.to).to eq [@invited_user_params[:email]]
          end

          it 'should register send email' do
            invited_user = User.last

            expect(invited_user.sent_email).to be true
          end
        end

        context 'when invitor has no rights on company' do
          before do
            sign_in tenant_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params, addto: 1,customer_id: customer_company}
          end
          it 'fails to create user' do
            expect do
              post :invite, params: {user: @invited_user_params, addto: 1, customer_id: customer_company}
            end.to change { User.count }.by(0)
          end
        end
      end

      context 'with selectable options' do
        context 'when invitor has rights' do
          before do
            tenant_user.company_users.create(company_id: company_company.id)
            customer_company.update_attributes!(parent_id: company_company.id)

            sign_in tenant_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:customer), company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params}
          end
          it 'creates user' do
            invited_user = User.last

            expect(invited_user.email).to eq(@invited_user_params[:email])
          end

          it 'should be a customer user' do
            invited_user = User.last

            expect(invited_user.profile_type_name).to eq(:customer)
          end

          it 'should be a registered user' do
            invited_user = User.last

            expect(invited_user.company_users.count).to eq 1
          end

          it 'should be registered with customer_company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_id).to eq customer_company.id
          end

          it 'should be registered on branch company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_branch_id).to eq branch.id
          end

          it 'redirects to members path' do
            expect(response).to redirect_to members_path
          end

          it 'should register invited by info' do
            invited_user = User.last

            expect(invited_user.invited_by_id).to eq(tenant_user.id)
          end

          it 'should send email' do
            last_email = ActionMailer::Base.deliveries.last

            expect(last_email.to).to eq [@invited_user_params[:email]]
          end

          it 'should register send email' do
            invited_user = User.last

            expect(invited_user.sent_email).to be true
          end
        end

        context 'when invitor has no rights' do
          before do
            another_company = create(:company_company)
            tenant_user.company_users.create(company_id: another_company.id)

            sign_in tenant_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:customer), company_users_attributes: { '0' => company_users_params} }
          end
          it 'fails to create user' do
            expect do
              post :invite, params: {user: @invited_user_params}
            end.to change { User.count }.by(0)
          end
          it 'redirects to root' do
            post :invite, params: {user: @invited_user_params}

            expect(response).to redirect_to root_path
          end
        end
      end
    end

    context 'by partner' do
      context 'with fixed add option' do
        context 'when invitor has rights on company' do
          before do
            partner_user.company_users.create(company_id: reseller_company.id)
            customer_company.update_attributes!(parent_id: reseller_company.id)

            sign_in partner_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params, addto: 1,customer_id: customer_company}
          end
          it 'creates user' do
            invited_user = User.last

            expect(invited_user.email).to eq(@invited_user_params[:email])
          end

          it 'should be a customer user' do
            invited_user = User.last

            expect(invited_user.profile_type_name).to eq(:customer)
          end

          it 'should be a registered user' do
            invited_user = User.last

            expect(invited_user.company_users.count).to eq 1
          end

          it 'should be registered with customer_company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_id).to eq customer_company.id
          end

          it 'should be registered on branch company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_branch_id).to eq branch.id
          end

          it 'redirects to resellers members path' do
            expect(response).to redirect_to members_path
          end

          it 'should register invited by info' do
            invited_user = User.last

            expect(invited_user.invited_by_id).to eq(partner_user.id)
          end

          it 'should send email' do
            last_email = ActionMailer::Base.deliveries.last

            expect(last_email.to).to eq [@invited_user_params[:email]]
          end

          it 'should register send email' do
            invited_user = User.last

            expect(invited_user.sent_email).to be true
          end
        end

        context 'when invitor has no rights on company' do
          before do
            sign_in partner_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params, addto: 1,customer_id: customer_company}
          end
          it 'fails to create user' do
            expect do
              post :invite, params: {user: @invited_user_params, addto: 1, customer_id: customer_company}
            end.to change { User.count }.by(0)
          end
        end
      end

      context 'with selectable options' do
        context 'for customer' do
          context 'when invitor has rights' do
            before do
              partner_user.company_users.create(company_id: reseller_company.id)
              customer_company.update_attributes!(parent_id: reseller_company.id)

              sign_in partner_user
              company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
              @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:customer), company_users_attributes: { '0' => company_users_params} }
              post :invite, params: {user: @invited_user_params}
            end
            it 'creates user' do
              invited_user = User.last

              expect(invited_user.email).to eq(@invited_user_params[:email])
            end

            it 'should be a customer user' do
              invited_user = User.last

              expect(invited_user.profile_type_name).to eq(:customer)
            end

            it 'should be a registered user' do
              invited_user = User.last

              expect(invited_user.company_users.count).to eq 1
            end

            it 'should be registered with customer_company' do
              invited_user = User.last

              expect(invited_user.company_users.first.company_id).to eq customer_company.id
            end

            it 'should be registered on branch company' do
              invited_user = User.last

              expect(invited_user.company_users.first.company_branch_id).to eq branch.id
            end

            it 'redirects to members path' do
              expect(response).to redirect_to members_path
            end

            it 'should register invited by info' do
              invited_user = User.last

              expect(invited_user.invited_by_id).to eq(partner_user.id)
            end

            it 'should send email' do
              last_email = ActionMailer::Base.deliveries.last

              expect(last_email.to).to eq [@invited_user_params[:email]]
            end

            it 'should register send email' do
              invited_user = User.last

              expect(invited_user.sent_email).to be true
            end
          end

          context 'when invitor has no rights' do
            before do
              partner_user.company_users.create(company_id: reseller_company.id)
              customer_company.update_attributes!(parent_id: company_company.id)

              sign_in partner_user
              company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
              @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:customer), company_users_attributes: { '0' => company_users_params} }
            end
            it 'fails to create user' do
              expect do
                post :invite, params: {user: @invited_user_params}
              end.to change { User.count }.by(0)
            end
            it 'redirects to root' do
              post :invite, params: {user: @invited_user_params}

              expect(response).to redirect_to root_path
            end
          end
        end

        context 'for partner' do
          context 'when invitor has rights' do
            before do
              partner_user.company_users.create(company_id: reseller_company.id)

              sign_in partner_user
              company_users_params = {company_id: reseller_company.id}
              @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:partner), company_users_attributes: { '0' => company_users_params} }
              post :invite, params: {user: @invited_user_params}
            end
            it 'creates user' do
              invited_user = User.last

              expect(invited_user.email).to eq(@invited_user_params[:email])
            end

            it 'should be a partner user' do
              invited_user = User.last

              expect(invited_user.profile_type_name).to eq(:partner)
            end

            it 'should be a registered user' do
              invited_user = User.last

              expect(invited_user.company_users.count).to eq 1
            end

            it 'should be registered with reseller_company' do
              invited_user = User.last

              expect(invited_user.company_users.first.company_id).to eq reseller_company.id
            end

            it 'redirects to members path' do
              expect(response).to redirect_to members_path
            end

            it 'should register invited by info' do
              invited_user = User.last

              expect(invited_user.invited_by_id).to eq(partner_user.id)
            end

            it 'should send email' do
              last_email = ActionMailer::Base.deliveries.last

              expect(last_email.to).to eq [@invited_user_params[:email]]
            end

            it 'should register send email' do
              invited_user = User.last

              expect(invited_user.sent_email).to be true
            end
          end

          context 'when invitor has no rights' do
            before do
              partner_user.company_users.create(company_id: reseller_company.id)
              another_reseller = create(:reseller_company, parent_id: company_company.id)

              sign_in partner_user
              company_users_params = {company_id: another_reseller.id}
              @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:partner), company_users_attributes: { '0' => company_users_params} }
            end
            it 'fails to create user' do
              expect do
                post :invite, params: {user: @invited_user_params}
              end.to change { User.count }.by(0)
            end
            it 'redirects to root' do
              post :invite, params: {user: @invited_user_params}

              expect(response).to redirect_to root_path
            end
          end
        end
      end

      context 'not permitted by selection' do
        context 'for tenant' do
            before do
              partner_user.company_users.create(company_id: reseller_company.id)

              sign_in partner_user
              company_users_params = {company_id: company_company.id}
              @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:tenant), company_users_attributes: { '0' => company_users_params} }
            end
            it 'fails to create user' do
              expect do
                post :invite, params: {user: @invited_user_params}
              end.to change { User.count }.by(0)
            end
            it 'redirects to root' do
              post :invite, params: {user: @invited_user_params}

              expect(response).to redirect_to root_path
            end
        end

        context 'for admin' do
            before do
              partner_user.company_users.create(company_id: reseller_company.id)

              sign_in partner_user
              company_users_params = {company_id: company_company.id}
              @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:admin), company_users_attributes: { '0' => company_users_params} }
            end
            it 'fails to create user' do
              expect do
                post :invite, params: {user: @invited_user_params}
              end.to change { User.count }.by(0)
            end
            it 'redirects to root' do
              post :invite, params: {user: @invited_user_params}

              expect(response).to redirect_to root_path
            end
        end
      end
    end

    context 'by customer' do
      context 'with fixed addto option' do
        context 'when invitor has rights on company' do
          before do
            customer_user.company_users.create(company_id: customer_company.id)
            customer_company.update_attributes!(parent_id: customer_company.id)

            sign_in customer_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params, addto: 1,customer_id: customer_company}
          end
          it 'creates user' do
            invited_user = User.last

            expect(invited_user.email).to eq(@invited_user_params[:email])
          end

          it 'should be a customer user' do
            invited_user = User.last

            expect(invited_user.profile_type_name).to eq(:customer)
          end

          it 'should be a registered user' do
            invited_user = User.last

            expect(invited_user.company_users.count).to eq 1
          end

          it 'should be registered with customer_company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_id).to eq customer_company.id
          end

          it 'should be registered on branch company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_branch_id).to eq branch.id
          end

          it 'redirects to resellers members path' do
            expect(response).to redirect_to members_path
          end

          it 'should register invited by info' do
            invited_user = User.last

            expect(invited_user.invited_by_id).to eq(customer_user.id)
          end

          it 'should send email' do
            last_email = ActionMailer::Base.deliveries.last

            expect(last_email.to).to eq [@invited_user_params[:email]]
          end

          it 'should register send email' do
            invited_user = User.last

            expect(invited_user.sent_email).to be true
          end
        end

        context 'when invitor has no rights on company' do
          before do
            sign_in customer_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params, addto: 1,customer_id: customer_company}
          end
          it 'fails to create user' do
            expect do
              post :invite, params: {user: @invited_user_params, addto: 1, customer_id: customer_company}
            end.to change { User.count }.by(0)
          end
        end
      end

      context 'with selectable option' do
        context 'when invitor has rights on company' do
          before do
            customer_user.company_users.create(company_id: customer_company.id)

            sign_in customer_user
            company_users_params = {company_id: customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:customer), company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params}
          end
          it 'creates user' do
            invited_user = User.last

            expect(invited_user.email).to eq(@invited_user_params[:email])
          end

          it 'should be a customer user' do
            invited_user = User.last

            expect(invited_user.profile_type_name).to eq(:customer)
          end

          it 'should be a registered user' do
            invited_user = User.last

            expect(invited_user.company_users.count).to eq 1
          end

          it 'should be registered with customer_company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_id).to eq customer_company.id
          end

          it 'should be registered on branch company' do
            invited_user = User.last

            expect(invited_user.company_users.first.company_branch_id).to eq branch.id
          end

          it 'redirects to resellers members path' do
            expect(response).to redirect_to members_path
          end

          it 'should register invited by info' do
            invited_user = User.last

            expect(invited_user.invited_by_id).to eq(customer_user.id)
          end

          it 'should send email' do
            last_email = ActionMailer::Base.deliveries.last

            expect(last_email.to).to eq [@invited_user_params[:email]]
          end

          it 'should register send email' do
            invited_user = User.last

            expect(invited_user.sent_email).to be true
          end
        end

        context 'when invitor has no rights on company' do
          before do
            customer_user.company_users.create(company_id: customer_company.id)
            another_customer_company = create(:customer_company)

            sign_in customer_user
            company_users_params = {company_id: another_customer_company.id, company_branch_id: branch.id}
            @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:customer), company_users_attributes: { '0' => company_users_params} }
            post :invite, params: {user: @invited_user_params}
          end
          it 'fails to create user' do
            expect do
              post :invite, params: {user: @invited_user_params}
            end.to change { User.count }.by(0)
          end
        end
      end

      context 'not permitted by selection' do
        context 'for tenant' do
            before do
              customer_user.company_users.create(company_id: customer_company.id)

              sign_in customer_user
              company_users_params = {company_id: company_company.id}
              @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:tenant), company_users_attributes: { '0' => company_users_params} }
            end
            it 'fails to create user' do
              expect do
                post :invite, params: {user: @invited_user_params}
              end.to change { User.count }.by(0)
            end
            it 'redirects to root' do
              post :invite, params: {user: @invited_user_params}

              expect(response).to redirect_to root_path
            end
        end

        context 'for admin' do
            before do
              customer_user.company_users.create(company_id: customer_company.id)

              sign_in customer_user
              company_users_params = {company_id: company_company.id}
              @invited_user_params = {first_name: 's', last_name: 'n', email: 'sn@example.com', profile_type: User::PROFILE_TYPES.index(:admin), company_users_attributes: { '0' => company_users_params} }
            end
            it 'fails to create user' do
              expect do
                post :invite, params: {user: @invited_user_params}
              end.to change { User.count }.by(0)
            end
            it 'redirects to root' do
              post :invite, params: {user: @invited_user_params}

              expect(response).to redirect_to root_path
            end
        end
      end
    end
  end

  describe '#update' do
    context 'by admin user' do
        before do
          sign_in admin_user
          company_users_params = {company_id: customer_company, company_branch_id: branch}
          put :update, params: { user: {first_name: 'NewName'}, company_users_attributes: { '0' => company_users_params }, id: customer_user }
        end
        it 'redirects to members path' do
          expect(response).to redirect_to members_path
        end

        it 'responds with notice' do
          expect(flash[:notice]).to eq  I18n.t('commons.successfully_updated')
        end

        it 'updates user' do
          customer_user.reload

          expect(customer_user.first_name).to eq('NewName')
        end

        # it 'updates company user' do
        #   customer_user.reload

        #   expect(customer_user.company_users.first.company_id).to eq(customer_company.id)
        # end
    end

    context 'by partner user' do
      context 'for his customer' do
        before do
          partner_user.company_users.create(company_id: reseller_company.id)
          customer_user.company_users.create(company_id: customer_company.id)
          sign_in partner_user
          company_users_params = {company_id: customer_company, company_branch_id: branch.id}
          put :update, params: { user: {first_name: 'NewName'}, company_users_attributes: { '0' => company_users_params }, id: customer_user.id }
        end
        it 'redirects to members path' do
          expect(response).to redirect_to members_path
        end

        it 'responds with notice' do
          expect(flash[:notice]).to eq  I18n.t('commons.successfully_updated')
        end

        it 'updates user' do
          customer_user.reload

          expect(customer_user.first_name).to eq('NewName')
        end

        it 'updates company user' do
          customer_user.reload

          expect(customer_user.company_users.first.company_id).to eq(customer_company.id)
        end
      end

      context 'if not his customer user' do
        it 'raises error' do
          partner_user.company_users.create(company_id: reseller_company.id)
          customer_user.company_users.create(company_id: create(:customer_company))
          sign_in partner_user
          company_users_params = {company_id: customer_company, company_branch_id: branch.id}
          customer_user.company_users.create(company_id: create(:customer_company))
          expect {
            put :update, params: { user: {first_name: 'NewName'}, company_users_attributes: { '0' => company_users_params }, id: customer_user.id }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
