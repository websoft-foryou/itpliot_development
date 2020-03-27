class EvaluationServicesUpdate < ActiveRecord::Migration
  def change
    add_column :evaluation_services, :position, :integer, default: 0
  end
end
