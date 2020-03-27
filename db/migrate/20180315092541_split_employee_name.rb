class SplitEmployeeName < ActiveRecord::Migration
  def up
    add_column :employees, :current_first_name, :string
    add_column :employees, :current_last_name, :string

    add_column :employee_evaluations, :employee_first_name, :string
    add_column :employee_evaluations, :employee_last_name, :string

    Employee.all.each do |e|
      e.current_first_name = (e.current_name || "").split(" ")[0..-2].join(" ")
      e.current_last_name = (e.current_name || "").split(" ").last
      e.save!(validate: false)
    end

    EmployeeEvaluation.all.each do |e|
      e.employee_first_name = (e.employee_name || "").split(" ")[0..-2].join(" ")
      e.employee_last_name = (e.employee_name || "").split(" ").last
      e.save!(validate: false)
    end

    remove_column :employees, :current_name
    remove_column :employee_evaluations, :employee_name
  end

  def down
    remove_column :employees, :current_first_name
    remove_column :employees, :current_last_name
    remove_column :employee_evaluations, :employee_first_name
    remove_column :employee_evaluations, :employee_last_name
  end
end
