class CurrentEmployeeData < ActiveRecord::Migration
  def up
    rename_column :employees, :name, :current_name
    rename_column :employees, :work_type, :current_work_type
    rename_column :employees, :monthly_hours, :current_monthly_hours
  end

  def down
    rename_column :employees, :current_name, :name
    rename_column :employees, :current_work_type, :work_type
    rename_column :employees, :current_monthly_hours, :monthly_hours
  end
end
