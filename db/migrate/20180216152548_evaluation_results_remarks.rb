class EvaluationResultsRemarks < ActiveRecord::Migration
  def change
    add_column :evaluation_results, :remarks, :text
  end
end
