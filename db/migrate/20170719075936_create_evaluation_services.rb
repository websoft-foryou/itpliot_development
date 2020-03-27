class CreateEvaluationServices < ActiveRecord::Migration
  def change
  	create_table :evaluation_services do |t|
  		t.integer :evaluation_id
  		t.integer :service_id
  	end
  end
end
