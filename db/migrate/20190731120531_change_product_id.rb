class ChangeProductId < ActiveRecord::Migration[5.2]
  def change
    rename_column :plans, :product_id, :quarter_product_id
    add_column :plans, :daily_product_id, :string

    Plan.find_each do |plan|
      plan.daily_product_id = "itp_bpa_pa1_d" if plan.company_type == 1 and plan.employees_from == 1 and plan.employees_to == 10
      plan.daily_product_id = "itp_bpa_pa2_d" if plan.company_type == 1 and plan.employees_from == 11 and plan.employees_to == 50
      plan.daily_product_id = "itp_bpa_pa3_d" if plan.company_type == 1 and plan.employees_from == 51 and plan.employees_to == 200
      plan.daily_product_id = "itp_bpa_pa4_d" if plan.company_type == 1 and plan.employees_from == 201

      plan.daily_product_id = "itp_bpa_cu1_d" if plan.company_type == 2 and plan.employees_from == 1 and plan.employees_to == 25
      plan.daily_product_id = "itp_bpa_cu2_d" if plan.company_type == 2 and plan.employees_from == 26 and plan.employees_to == 100
      plan.daily_product_id = "itp_bpa_cu3_d" if plan.company_type == 2 and plan.employees_from == 101 and plan.employees_to == 500
      plan.daily_product_id = "itp_bpa_cu4_d" if plan.company_type == 2 and plan.employees_to == 1000
      plan.daily_product_id = "itp_bpa_cu5_d" if plan.company_type == 2 and plan.employees_from == 1001

      plan.save!
    end
  end
end
