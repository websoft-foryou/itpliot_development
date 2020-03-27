class CompaniesAddcolumns < ActiveRecord::Migration
  def change
  	add_column :companies, :name2, :string
  	add_column :companies, :phone, :string
  	add_column :companies, :mobile, :string
  	add_column :companies, :email, :string
  	add_column :companies, :url, :string
  	add_column :companies, :remarks, :text
  end
end
