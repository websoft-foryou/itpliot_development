class AddProductIdToPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :product_id, :string
    Plan.find_each do |plan|
      plan.product_id = "itp_bpa_pa1_q" if plan.company_type == 1 and plan.employees_from == 1 and plan.employees_to == 10
      plan.product_id = "itp_bpa_pa2_q" if plan.company_type == 1 and plan.employees_from == 11 and plan.employees_to == 50
      plan.product_id = "itp_bpa_pa3_q" if plan.company_type == 1 and plan.employees_from == 51 and plan.employees_to == 200
      plan.product_id = "itp_bpa_pa4_q" if plan.company_type == 1 and plan.employees_from == 201

      plan.product_id = "itp_bpa_cu1_q" if plan.company_type == 2 and plan.employees_from == 1 and plan.employees_to == 25
      plan.product_id = "itp_bpa_cu2_q" if plan.company_type == 2 and plan.employees_from == 26 and plan.employees_to == 100
      plan.product_id = "itp_bpa_cu3_q" if plan.company_type == 2 and plan.employees_from == 101 and plan.employees_to == 500
      plan.product_id = "itp_bpa_cu4_q" if plan.company_type == 2 and plan.employees_to == 1000
      plan.product_id = "itp_bpa_cu5_q" if plan.company_type == 2 and plan.employees_from == 1001

      plan.save!
    end
  end
end
