class EvaluationResultSupportingServices < ActiveRecord::Migration
  def change
  	add_column :evaluation_results, :supporting_services, :text
  end
end
