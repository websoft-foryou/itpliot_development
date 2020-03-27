class ServiceTranslation3 < ActiveRecord::Migration
  def up
  	add_column :services, :purpose, :string
  	Service.add_translation_fields! :purpose => :string
  	
  	Service.order(:id).each do |service|
  		t = service.translations.where(:locale => :en).first
  		t = service.translations.new({:locale => :en}) if !t
  		t.purpose = service.purpose_en
  		t.name = service.name_en
  		t.save

  		t = service.translations.where(:locale => :de).first
  		t = service.translations.new({:locale => :de}) if !t
  		t.purpose = service.purpose_de
  		t.name = service.name_de
  		t.save
  	end

  end

  def down
  	remove_column :service_translations, :purpose
  end
end
