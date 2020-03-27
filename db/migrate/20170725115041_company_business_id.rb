class CompanyBusinessId < ActiveRecord::Migration
  def change
  	remove_column :companies, :industry_id
  	add_column :companies, :business_id, :integer
  end
end
