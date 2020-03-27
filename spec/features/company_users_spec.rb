require "rails_helper"

# - select tenants with no company
# - associates company to tenant
# - delete association

RSpec.feature "Company User management", :type => :feature do
  let(:admin_user){ create(:admin_user) }
  let(:company_company){ create(:company_company) }
  let(:tenant_user){ create(:tenant_user) }

  scenario "Admin associates company to tenant" do
    login(admin_user)
    visit company_path(company_company)

    first('input.single_select2', visible: false).set(tenant_user.id)
    click_button I18n.t('commons.add')

    expect(page).to have_content(I18n.t('company_users.user_sucessfully_added'))
  end

  scenario "Admin deletes company tenant association" do
    login(admin_user)

    company_user = create(:company_user, company_id: company_company.id, user_id: tenant_user.id)
    visit company_path(company_company)

    within "#cuu_id_#{company_user.id}" do
      click_link I18n.t('commons.delete')
    end
    expect(page).to_not have_content(company_user.user.email)
    expect(page).to_not have_content(I18n.t('commons.delete'))
  end


end
