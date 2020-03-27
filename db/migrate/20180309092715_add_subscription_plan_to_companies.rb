class AddSubscriptionPlanToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :premium_from, :date
    add_column :companies, :premium_until, :date
  end
end
