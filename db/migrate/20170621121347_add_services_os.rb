class AddServicesOs < ActiveRecord::Migration
def change
  	add_column :evaluation_result_servers, :os, :string
  end
end
