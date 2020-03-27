class EvaluationResultByUser < ActiveRecord::Migration
  def change
  	add_column :evaluation_results, :created_by, :integer
  	add_column :evaluation_results, :updated_by, :integer
  end
end
