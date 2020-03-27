class EvaluationStatuses < ActiveRecord::Migration
  def change
  	add_column :evaluations, :status, :integer, :default => 0
  end
end
