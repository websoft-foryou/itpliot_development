class EvaluationPublishedBy < ActiveRecord::Migration
  def change
  	add_column :evaluations, :published_by, :integer
  end
end
