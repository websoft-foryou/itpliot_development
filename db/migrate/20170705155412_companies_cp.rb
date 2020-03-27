class CompaniesCp < ActiveRecord::Migration
  def change
  	add_column :companies, :contact_person, :string
  end
end
