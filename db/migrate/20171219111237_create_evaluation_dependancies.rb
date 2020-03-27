class CreateEvaluationDependancies < ActiveRecord::Migration
  def change
    create_table :evaluation_dependances do |t|
      t.integer :evaluation_id
      t.integer :dependant_service_id
      t.integer :depending_service_id
    end
  end
end
