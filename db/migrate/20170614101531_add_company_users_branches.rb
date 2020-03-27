class AddCompanyUsersBranches < ActiveRecord::Migration
  def change
  	add_column :company_users, :company_branch_id, :integer
  end
end
