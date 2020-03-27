class ResultsEnahancements < ActiveRecord::Migration
  def change
  	add_column :evaluation_results, :enhancements, :string
  end
end
