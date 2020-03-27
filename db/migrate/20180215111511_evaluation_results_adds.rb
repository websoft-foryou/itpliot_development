class EvaluationResultsAdds < ActiveRecord::Migration
  def change
    add_column :evaluation_results, :usage_description, :text
    add_column :evaluation_results, :assessment_description, :text
    add_column :evaluation_results, :assessment_status, :integer, default: 0, null: false
    add_column :evaluation_results, :recommended_measures, :text
  end
end
