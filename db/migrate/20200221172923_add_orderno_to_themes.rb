class AddOrdernoToThemes < ActiveRecord::Migration[5.2]
  def change
    add_column :themes, :orderno, :integer
  end
end
