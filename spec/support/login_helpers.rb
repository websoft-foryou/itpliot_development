def login(user)
  visit new_user_session_path

  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Sign in'
end

def login_customer
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    customer_user = FactoryBot.create(:customer_user)
    sign_in :customer_user, user
  end
end

