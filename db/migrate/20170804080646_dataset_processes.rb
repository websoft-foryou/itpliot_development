class DatasetProcesses < ActiveRecord::Migration
  def change
  	create_table :evaluation_processes do |t|
  		t.integer :evaluation_id
  		t.integer :work_process_id
  	end
  	create_table :evaluation_processes_results do |t|
  		t.integer :evaluation_process_id
  		t.integer :evaluation_result_id
  	end
  end
end
