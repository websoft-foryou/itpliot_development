class ChangeServiceTimeFields < ActiveRecord::Migration[5.2]
  def change
    change_column :evaluation_results, :recovery_time, :decimal
    change_column :evaluation_results, :guaranteed_recovery_time, :decimal
  end
end
