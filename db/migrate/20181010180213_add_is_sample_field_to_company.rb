class AddIsSampleFieldToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :is_sample, :boolean, default: false
  end
end
