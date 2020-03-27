class AddResultsLinks < ActiveRecord::Migration
  def change
    add_column :evaluation_results, :links, :text
  end
end
