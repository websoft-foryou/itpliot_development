class BusinessesTranslations < ActiveRecord::Migration
  def change
  	add_column :businesses, :name, :string
  	Business.create_translation_table! :name => :string
  	Business.order(:id).each do |item|
  		t = item.translations.where(:locale => :en).first
  		t = item.translations.new({:locale => :en}) if !t
  		t.name = item.name_en
  		t.save
  		t = item.translations.where(:locale => :de).first
  		t = item.translations.new({:locale => :de}) if !t
  		t.name = item.name_de
  		t.save
  	end
  end
end
