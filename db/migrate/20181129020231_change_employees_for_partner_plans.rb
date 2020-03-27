class ChangeEmployeesForPartnerPlans < ActiveRecord::Migration[5.2]
  def change
    p1 = Plan.where("employees_to=? AND company_type=?", 25, Company::COMPANY_TYPES.index(:partner)).first
    if p1
      p1.update_attribute(:employees_to, 50)
    end

    p2 = Plan.where("employees_from=? AND company_type=?", 26, Company::COMPANY_TYPES.index(:partner)).first
    if p2
      p2.update_attribute(:employees_from, 51)
    end
  end
end
