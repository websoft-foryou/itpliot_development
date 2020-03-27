require "rails_helper"

# - create new company and message + redirect to show
# - after create in display page add user - search tenant users with no company associated
# - delete company and message + redirect to index

RSpec.feature "Companies management", :type => :feature do
  let(:admin_user){ create(:admin_user) }
  let(:company_company){ create(:company_company) }

  scenario "Admin creates a new company" do
    login(admin_user)
    visit "/companies/new"

    fill_in I18n.t('companies.form.name'), :with => "New Company"
    fill_in I18n.t('companies.form.contact_person'), :with => "Person"
    click_button I18n.t('commons.save')

    expect(page).to have_content(I18n.t('commons.successfully_created'))
  end

  scenario "Admin can edit company" do
    login(admin_user)
    visit edit_company_path(company_company)

    fill_in I18n.t('companies.form.name'), :with => "New Name Company"
    click_button I18n.t('commons.save')

    expect(page).to have_content(I18n.t('commons.successfully_updated'))
    expect(page).to have_content('New Name Company')
  end

  scenario "Admin can delete company" do
    login(admin_user)
    visit edit_company_path(company_company)

    expect(page).to have_content(company_company.name)
    expect(page).to have_content(I18n.t('commons.delete'))
    
    click_link I18n.t('commons.delete')
    expect(page).to have_content I18n.t('commons.successfully_deleted')
  end

end
