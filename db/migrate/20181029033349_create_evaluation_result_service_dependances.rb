class CreateEvaluationResultServiceDependances < ActiveRecord::Migration[5.2]
  def change
    create_table :evaluation_result_service_dependances do |t|
      t.integer :evaluation_result_id
      t.integer :service_id
      t.integer :service_depending_id
    end
  end
end
