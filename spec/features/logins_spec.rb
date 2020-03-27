require 'rails_helper'

RSpec.feature 'Admin Login', type: :feature do
  let(:admin_user){ create(:admin_user) }

  scenario 'admin can log in' do
    visit root_path

    fill_in 'user_email', :with => admin_user.email
    fill_in 'user_password', :with => admin_user.password
    click_button "Sign in"

    expect(page).to have_text(I18n.t('devise.sessions.signed_in'))
    expect(page).to have_text(I18n.t('users.log_out'))
  end
end
