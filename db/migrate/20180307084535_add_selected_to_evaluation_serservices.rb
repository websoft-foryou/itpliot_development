class AddSelectedToEvaluationSerservices < ActiveRecord::Migration
  def change
    add_column :evaluation_services, :selected, :boolean, default: false
  end
end
