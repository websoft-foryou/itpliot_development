class CustomersIndustry < ActiveRecord::Migration
  def change
  	add_column :companies, :industry, :string
  end
end
