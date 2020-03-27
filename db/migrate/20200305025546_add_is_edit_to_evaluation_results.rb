class AddIsEditToEvaluationResults < ActiveRecord::Migration[5.2]
  def change
    add_column :evaluation_results, :is_edit, :bool
  end
end
