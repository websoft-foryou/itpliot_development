class ChangeInvoiceDatesType < ActiveRecord::Migration[5.2]
  def change
    change_column :invoices, :issued_at, :date
    rename_column :invoices, :issued_at, :issued_date
    change_column :invoices, :due_to, :date
    rename_column :invoices, :due_to, :due_date
  end
end
