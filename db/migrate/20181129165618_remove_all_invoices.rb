class RemoveAllInvoices < ActiveRecord::Migration[5.2]
  def change
    Invoice.delete_all
  end
end
