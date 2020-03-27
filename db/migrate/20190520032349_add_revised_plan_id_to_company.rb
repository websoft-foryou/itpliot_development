class AddRevisedPlanIdToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :revised_plan_id, :integer
    Company.where("plan_id IS NOT NULL").each do |company|
      company.update_attribute(:revised_plan_id, company.plan_id)
    end
  end
end
