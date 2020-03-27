class ChangeEmployeeDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :employee_domains, :evaluation_id, :integer

    EmployeeEvaluation.all.each do |ee|
      EmployeeDomain.where(:employee_id => ee.employee_id).each do |ed|
        ed.update_attribute(:evaluation_id, ee.evaluation_id)
      end
    end
  end
end
