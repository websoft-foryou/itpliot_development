class AddDeletedFieldToCompanyBranches < ActiveRecord::Migration[5.2]
  def change
    add_column :company_branches, :deleted, :boolean, default: false
  end
end
