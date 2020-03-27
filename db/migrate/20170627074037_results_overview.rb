class ResultsOverview < ActiveRecord::Migration
  def change
  	add_column :evaluation_results, :overview, :text
  end
end
