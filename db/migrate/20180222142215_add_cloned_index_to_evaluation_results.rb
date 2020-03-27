class AddClonedIndexToEvaluationResults < ActiveRecord::Migration
  def change
    add_column :evaluation_results, :cloned_index, :string, default: ''
  end
end
