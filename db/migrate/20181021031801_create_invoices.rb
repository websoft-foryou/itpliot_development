class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.integer :company_id
      t.integer :plan_id
      t.datetime :issued_at
      t.datetime :due_to
      t.string :internal_no
      t.integer :status, :default => Invoice::STATUSES.index(:open)
      t.integer :created_by

      t.timestamps
    end
  end
end
