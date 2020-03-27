class EmployeeResultsActivities < ActiveRecord::Migration

	ACTIVITY_TYPES = {
		'e' => 'evaluation_and_planning',
		't' => 'test',
		'o' => 'order_management',
		'v' => 'vendor_management',
		'i' => 'instalation',
		'c' => 'configuration',
		'a' => 'administration',
		'm' => 'monitoring',
		'u' => 'updates',
		'l1' => 'level1_support',
		'l2' => 'level2_support',
		'l3'  =>'level3_support'
	}

  def change
  	ACTIVITY_TYPES.values.each do |c|
  		add_column :employee_evaluation_results, c.to_sym, :boolean, default: false
  	end
  end
end
