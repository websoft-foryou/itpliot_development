class ChangePremiumPeriodType < ActiveRecord::Migration[5.2]
  def change
      change_column :invoices, :issued_date, :datetime
      change_column :invoices, :due_date, :datetime
      change_column :invoices, :premium_from, :datetime
      change_column :invoices, :premium_until, :datetime
      change_column :companies, :premium_from, :datetime
      change_column :companies, :premium_until, :datetime
  end
end
