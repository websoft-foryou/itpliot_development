class CreateEmployees < ActiveRecord::Migration
  def change
  	create_table :employees do |t|
  		t.string :name
  		t.integer :customer_id
  	end
    create_table :employee_evaluations do |t|
      t.integer :employee_id
      t.integer :evaluation_id
      t.integer :hours_intern
      t.integer :hours_extern
    end
  	create_table :employee_evaluation_results do |t|
  		t.integer :employee_evaluation_id
  		t.integer :evaluation_result_id
  	end
  end
end
