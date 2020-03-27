class ResultsSupportingSupported < ActiveRecord::Migration
  def change
  	remove_column :evaluation_results, :supporting_services
  	remove_column :evaluation_results, :supported_services
  end
end
