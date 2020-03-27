class AddResultsDistributor < ActiveRecord::Migration
  def change
    add_column :evaluation_results, :distributor, :string
    add_column :evaluation_results, :planned_distributor, :string
  end
end
