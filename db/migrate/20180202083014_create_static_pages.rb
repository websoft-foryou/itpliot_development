class CreateStaticPages < ActiveRecord::Migration
  def change
    create_table :static_pages do |t|
      t.string :title
      t.string :uid, limit: 10
      t.string :locale, limit: 3
      t.text :description
      t.integer :user_type_permission
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    add_index :static_pages, :uid
  end
end
