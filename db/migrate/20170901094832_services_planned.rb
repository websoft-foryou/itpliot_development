class ServicesPlanned < ActiveRecord::Migration
  def change
    add_column :evaluation_results, :planned_cloud_service, :boolean
    add_column :evaluation_results, :planned_supplier, :string
    add_column :evaluation_results, :planned_servers_count, :integer
    add_column :evaluation_results, :planned_appliances_count, :integer
    add_column :evaluation_results, :planned_users_count, :integer
    add_column :evaluation_results, :planned_hours_intern, :integer
    add_column :evaluation_results, :planned_hours_extern, :integer
    add_column :evaluation_results, :planned_capex, :float
    add_column :evaluation_results, :planned_opex, :float
  end
end
