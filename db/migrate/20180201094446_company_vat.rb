class CompanyVat < ActiveRecord::Migration
  def change
    add_column :companies, :vat_number, :string, default: '', null: false
    Company.update_all("vat_number = id")
  end
end
