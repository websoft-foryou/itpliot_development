class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :company_type, default: 0

      t.timestamps
    end
  end
end
