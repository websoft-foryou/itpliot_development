class ChangeLocationBranchId < ActiveRecord::Migration
  def change
  	add_column :locations, :company_branch_id, :integer
  	remove_column :locations, :company_id
  end
end
