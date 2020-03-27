class CreateEvaluations < ActiveRecord::Migration
  def up

  	create_table :evaluations do |t|
  		t.integer :customer_id
  		t.integer :company_id
  		t.string :name
  		t.integer :created_by
  		t.timestamps
  	end

  	create_table :evaluation_results do |t|
  		t.integer :evaluation_id
  		t.integer :service_id
  		t.boolean :cloud_service
  		t.string :supplier
  		t.integer :servers_count
  		t.integer :appliances_count
  		t.integer :users_count
  		t.integer :gb_reserved
  		t.integer :gb_used
  		t.integer :supported_services
  		t.float :capex
  		t.float :opex
  		t.integer :hours_extern
  		t.integer :hours_intern
  		t.integer :recovery_time
  		t.string :impact
  		t.float :failure_impact_per_day
  		t.string :future_strategy
  		t.string :additional_services

  		t.timestamps
  	end
  end

  def down
  	drop_table :evaluation_results
  	drop_table :evaluations
  end
end
