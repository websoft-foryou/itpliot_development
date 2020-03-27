class ResultAppliances < ActiveRecord::Migration
  def change
    create_table :evaluation_result_appliances do |t|
      t.integer :evaluation_result_id
      t.string :name
      t.string :tech_system
      t.string :info_details
    end
  end
end
