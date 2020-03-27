class CreateThemeServices < ActiveRecord::Migration
  def change
  	create_table :theme_services do |t|
  		t.integer :theme_id
  		t.integer :service_id
  	end
  end
end
