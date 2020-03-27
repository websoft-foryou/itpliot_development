class AddPlanColumnsToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :will_continue_plan, :boolean
  end
end
