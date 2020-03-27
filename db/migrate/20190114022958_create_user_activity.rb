class CreateUserActivity < ActiveRecord::Migration[5.2]
  def change
    create_table :user_activities do |t|
      t.integer :user_id
      t.integer :action_type
      t.string :description

      t.timestamps
    end
  end
end
