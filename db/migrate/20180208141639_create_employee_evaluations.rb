class CreateEmployeeEvaluations < ActiveRecord::Migration
  def up
    create_table :employee_evaluations do |t|
      t.integer :employee_id, null: false
      t.integer :evaluation_id, null: false
      t.string :employee_name, null: false
      t.integer :employee_work_type, null: false, default: 0
      t.integer :employee_monthly_hours, null: false, default: 0
    end

    Company.customer.find_each do |customer|
      employees = customer.employees
      customer.customer_evaluations.each do |evaluation|
        employees.each do |employee|
          ee = EmployeeEvaluation.where(employee_id: employee, evaluation_id: evaluation).first_or_initialize
          ee.employee_name = employee.current_name
          ee.employee_work_type = employee.current_work_type
          ee.employee_monthly_hours = employee.current_monthly_hours
          ee.save!
        end
      end
    end

  end

  def down
    drop_table :employee_evaluations
  end
end
