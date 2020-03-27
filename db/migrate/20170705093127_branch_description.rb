class BranchDescription < ActiveRecord::Migration
  def change
  	add_column :company_branches, :description, :string
  end
end
