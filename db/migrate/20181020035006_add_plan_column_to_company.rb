class AddPlanColumnToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :plan_id, :integer
  end
end
