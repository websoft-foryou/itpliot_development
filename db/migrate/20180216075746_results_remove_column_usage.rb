class ResultsRemoveColumnUsage < ActiveRecord::Migration
  def change
    remove_column :evaluation_results, :usage_description
  end
end
