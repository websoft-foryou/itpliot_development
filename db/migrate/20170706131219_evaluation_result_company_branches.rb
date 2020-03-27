class EvaluationResultCompanyBranches < ActiveRecord::Migration
  def change
  	create_table :evaluation_result_company_branches do |t|
  		t.integer :evaluation_result_id
  		t.integer :company_branch_id
  	end
  end
end
