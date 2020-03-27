class EvaluationUpdatedBy < ActiveRecord::Migration
  def change
  	add_column :evaluations, :updated_by, :integer
  end
end
