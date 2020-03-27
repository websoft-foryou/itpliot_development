class AddPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.integer :employees_from
      t.integer :employees_to
      t.decimal :price
      t.integer :company_type
    end

    Plan.create(employees_from: 1, employees_to: 10, price: 50, company_type: Company::COMPANY_TYPES.index(:partner))
    Plan.create(employees_from: 11, employees_to: 25, price: 100, company_type: Company::COMPANY_TYPES.index(:partner))
    Plan.create(employees_from: 26, employees_to: 200, price: 200, company_type: Company::COMPANY_TYPES.index(:partner))
    Plan.create(employees_from: 201, employees_to: 1000000, price: 250, company_type: Company::COMPANY_TYPES.index(:partner))

    Plan.create(employees_from: 1, employees_to: 25, price: 50, company_type: Company::COMPANY_TYPES.index(:customer))
    Plan.create(employees_from: 26, employees_to: 100, price: 100, company_type: Company::COMPANY_TYPES.index(:customer))
    Plan.create(employees_from: 101, employees_to: 500, price: 200, company_type: Company::COMPANY_TYPES.index(:customer))
    Plan.create(employees_from: 500, employees_to: 1000, price: 350, company_type: Company::COMPANY_TYPES.index(:customer))
    Plan.create(employees_from: 1001, employees_to: 1000000, price: 500, company_type: Company::COMPANY_TYPES.index(:customer))

  end
end
