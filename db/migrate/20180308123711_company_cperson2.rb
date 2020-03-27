class CompanyCperson2 < ActiveRecord::Migration
  def change
    add_column :companies, :contact_person2, :string
    add_column :companies, :phone2, :string
    add_column :companies, :mobile2, :string
    add_column :companies, :email2, :string
  end
end
