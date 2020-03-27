class ChangeServiceSizeFields < ActiveRecord::Migration[5.2]
  def change
    change_column :evaluation_results, :gb_reserved, :decimal
    change_column :evaluation_results, :gb_used, :decimal
  end
end
