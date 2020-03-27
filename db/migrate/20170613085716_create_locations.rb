class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.decimal :latitude
      t.decimal :longitude
      t.string :city
      t.string :country
      t.string :address, limit: 500
      t.integer :company_id
    end
  end
end
