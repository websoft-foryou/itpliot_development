class AddClonedIndexToEvaluationService < ActiveRecord::Migration[5.2]
  def change
    add_column :evaluation_services, :cloned_index, :string, default: ""
  end
end
