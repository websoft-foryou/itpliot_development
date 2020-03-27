class AddGuaranteedRecoveryToEvaluationResults < ActiveRecord::Migration
  def change
    add_column :evaluation_results, :guaranteed_recovery_time, :integer
  end
end
