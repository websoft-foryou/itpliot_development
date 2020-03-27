class EvaluationResultsAttInfo < ActiveRecord::Migration
  def change
  	add_column :evaluation_results, :service_attributes_info, :text
  end
end
