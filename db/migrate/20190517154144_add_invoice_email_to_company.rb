class AddInvoiceEmailToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :invoice_email, :string
  end
end
