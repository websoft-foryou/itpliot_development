class ClearPlanIdFreemiumCompany < ActiveRecord::Migration[5.2]
  def change
    Company.find_each do |company|
      if !company.premium?
        company.plan_id = nil
        company.premium_from = nil
        company.premium_until = nil
        company.save!(validate: false)
      end
    end
  end
end
