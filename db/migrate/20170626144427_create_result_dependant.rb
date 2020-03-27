class CreateResultDependant < ActiveRecord::Migration
  def change
  	create_table :result_dependant_services do |t|
  		t.integer :evaluation_result_id
  		t.integer :service_id
  	end
  end
end
