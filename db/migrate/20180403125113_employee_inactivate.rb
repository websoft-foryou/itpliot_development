class EmployeeInactivate < ActiveRecord::Migration
  def change
    add_column :employees, :disabled_at, :datetime
  end
end
