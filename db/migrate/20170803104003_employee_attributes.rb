class EmployeeAttributes < ActiveRecord::Migration
  def change
  	add_column :employees, :work_type, :integer, default: 0
  	add_column :employees, :monthly_hours, :integer, default: 0
  end
end
