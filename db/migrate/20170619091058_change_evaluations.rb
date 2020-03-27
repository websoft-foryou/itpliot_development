class ChangeEvaluations < ActiveRecord::Migration
  def up
  	Evaluation.scoped.destroy_all
  	
  	add_column :evaluation_results, :company_branch_id, :integer

  	create_table :evaluation_result_servers do |t|
  		t.integer :evaluation_result_id
  		t.string :name
  		t.string :details
  		t.integer :gb_reserved
  		t.integer :gb_used
  	end

  	create_table :evaluation_result_services do |t|
  		t.integer :evaluation_result_id
  		t.string :service_id
  	end

  	create_table :evaluation_result_files do |t|
  		t.integer :evaluation_result_id
  		t.string :asset_file_name
  		t.string :asset_content_type
  		t.string :asset_updated_at
  	end
  end

  def down
  end
end
