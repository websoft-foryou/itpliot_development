class AddIsDspFieldToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :is_dsp, :boolean
  end
end
