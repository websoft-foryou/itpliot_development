class CreateCompanyBranches < ActiveRecord::Migration
  def up
  	drop_table :customers
  	create_table :company_branches do |t|
  		t.integer :company_id
  		t.string :name
  		t.timestamps
  	end

    add_column :companies, :parent_id, :integer
  end

  def down

  	drop_table :company_branches
  	create_table :customers do |t|
  		t.string :name
  	end
  end
end
