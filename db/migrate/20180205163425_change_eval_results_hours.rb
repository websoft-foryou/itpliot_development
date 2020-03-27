class ChangeEvalResultsHours < ActiveRecord::Migration
  def change
    change_column :evaluation_results, :hours_extern, :decimal, :precision => 10, :scale => 2
    change_column :evaluation_results, :hours_intern, :decimal, :precision => 10, :scale => 2
    change_column :evaluation_results, :planned_hours_extern, :decimal, :precision => 10, :scale => 2
    change_column :evaluation_results, :planned_hours_intern, :decimal, :precision => 10, :scale => 2
  end
end
