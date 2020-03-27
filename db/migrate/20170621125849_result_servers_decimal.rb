class ResultServersDecimal < ActiveRecord::Migration
  def change
  	remove_column :evaluation_result_servers, :gb_reserved
  	remove_column :evaluation_result_servers, :gb_used
  	add_column :evaluation_result_servers, :gb_reserved, :decimal, precision: 15, scale: 2
  	add_column :evaluation_result_servers, :gb_used, :decimal, precision: 15, scale: 2
  end
end
