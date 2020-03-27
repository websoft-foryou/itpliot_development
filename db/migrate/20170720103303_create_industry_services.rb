class CreateIndustryServices < ActiveRecord::Migration
  def change
  	create_table :industry_services do |t|
  		t.integer :industry_id
  		t.integer :service_id
  	end
  end
end
