class ResultsCount < ActiveRecord::Migration
  def change
  	add_column :evaluation_results, :result_dependant_services_count, :integer, :default => 0
  	add_column :evaluation_results, :result_depending_services_count, :integer, :default => 0
  end
end
