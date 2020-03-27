class LocationAddress2 < ActiveRecord::Migration
  def change
  	add_column :locations, :address2, :string
  end
end
