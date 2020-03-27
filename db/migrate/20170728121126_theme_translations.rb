class ThemeTranslations < ActiveRecord::Migration
  def change
  	Theme.create_translation_table! :name => :string
  	Theme.order(:id).each do |item|
  		t = item.translations.where(:locale => :en).first
  		t = item.translations.new({:locale => :en}) if !t
  		t.name = item.name
  		t.save
  		t = item.translations.where(:locale => :de).first
  		t = item.translations.new({:locale => :de}) if !t
  		t.name = item.name_de
  		t.save
  	end
  end
end
