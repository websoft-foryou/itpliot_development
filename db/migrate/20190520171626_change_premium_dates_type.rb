class ChangePremiumDatesType < ActiveRecord::Migration[5.2]
  def change
    change_column :companies, :premium_from, :date
    change_column :companies, :premium_until, :date
    change_column :invoices, :premium_from, :date
    change_column :invoices, :premium_until, :date
  end
end
