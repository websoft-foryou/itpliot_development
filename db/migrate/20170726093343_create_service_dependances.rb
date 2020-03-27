class CreateServiceDependances < ActiveRecord::Migration
  def change
    create_table :service_dependances do |t|
      t.integer :service_id
      t.integer :depending_id

      t.timestamps
    end
  end
end
