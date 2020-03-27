class CreateServices < ActiveRecord::Migration
  def up

  	create_table :services do |t|
  		t.string :code

  		t.integer :owner_id

  		t.string :name_en
  		t.string :name_de

  		t.string :purpose_en
  		t.string :purpose_de
  		
  		t.timestamps
  	end
  end

  def down
    drop_table :services
  end
end
