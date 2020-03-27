class DelEvaluationDependances < ActiveRecord::Migration
  def up
    drop_table :evaluation_dependances
  end

  def down
    create_table :evaluation_dependances do |t|
      t.integer :evaluation_id
      t.integer :dependant_service_id
      t.integer :depending_service_id
    end
  end
end
