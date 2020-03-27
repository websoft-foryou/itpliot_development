class IndustriesShortName < ActiveRecord::Migration
  def change
  	add_column :industries, :short_name_en, :string
  	add_column :industries, :short_name_de, :string
  end
end
