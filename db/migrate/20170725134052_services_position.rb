class ServicesPosition < ActiveRecord::Migration
  def change
  	add_column :services, :position, :integer, :default => 0
  end
end
