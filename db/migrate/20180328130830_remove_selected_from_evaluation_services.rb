class RemoveSelectedFromEvaluationServices < ActiveRecord::Migration
  def up
    remove_column :evaluation_services, :selected
  end

  def down
    add_column :evaluation_services, :selected, :boolean, default: false
  end
end
