class RemoveCreatedByFromInvoice < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :created_by
  end
end
