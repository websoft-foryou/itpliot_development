class CompanyBlockedBy < ActiveRecord::Migration
  def change
  	add_column :companies, :blocked_by, :integer
  	add_column :companies, :blocked_at, :datetime
  end
end
