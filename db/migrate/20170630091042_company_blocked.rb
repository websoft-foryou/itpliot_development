class CompanyBlocked < ActiveRecord::Migration
  def change
  	add_column :companies, :is_blocked, :boolean, default: false
  end
end
