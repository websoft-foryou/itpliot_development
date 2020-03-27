class CreateLicenses < ActiveRecord::Migration[5.2]
  def change
    create_table :licenses do |t|
      t.string :name
      t.float :price
      t.integer :days
      t.integer :incl_freemium
      t.integer :incl_premium
      t.integer :incl_partner
      t.timestamps
    end
  end
end
