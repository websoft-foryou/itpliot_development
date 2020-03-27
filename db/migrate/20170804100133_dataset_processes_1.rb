class DatasetProcesses1 < ActiveRecord::Migration
  def change
  	rename_table :evaluation_processes_results, :evaluation_process_results
  end
end
