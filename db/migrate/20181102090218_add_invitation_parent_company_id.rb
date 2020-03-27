class AddInvitationParentCompanyId < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :invitation_parent_company_id, :integer
  end
end
