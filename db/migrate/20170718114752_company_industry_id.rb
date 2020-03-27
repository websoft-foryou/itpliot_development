class CompanyIndustryId < ActiveRecord::Migration
  def change
  	remove_column :companies, :industry
  	add_column :companies, :industry_id, :integer
  end
end
