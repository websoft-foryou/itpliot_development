class AddPremiumDatesToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :premium_from, :datetime
    add_column :invoices, :premium_until, :datetime
  end
end
