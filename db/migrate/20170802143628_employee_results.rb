class EmployeeResults < ActiveRecord::Migration
  def change
  	drop_table :employee_evaluations
  	drop_table :employee_evaluation_results
  	create_table :employee_evaluation_results do |t|
  		t.integer :employee_id
  		t.integer :evaluation_result_id
  	end
  end
end
