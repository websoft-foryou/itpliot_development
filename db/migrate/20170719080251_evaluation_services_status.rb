class EvaluationServicesStatus < ActiveRecord::Migration
  def change
  	add_column :evaluation_services, :status, :integer, :default => 0
  end
end
