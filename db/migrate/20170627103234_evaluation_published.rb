class EvaluationPublished < ActiveRecord::Migration
  def change
  	add_column :evaluations, :published_at, :datetime
  end
end
