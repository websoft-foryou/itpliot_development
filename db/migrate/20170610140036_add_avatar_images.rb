class AddAvatarImages < ActiveRecord::Migration
  def up
  	add_column :users, :avatar_file_name, :string
  	add_column :users, :avatar_content_type, :string

  	add_column :companies, :avatar_file_name, :string
  	add_column :companies, :avatar_content_type, :string

  end

  def down
  	drop_table :users, :avatar_file_name
  	drop_table :users, :avatar_content_type

  	drop_table :companies, :avatar_file_name
  	drop_table :companies, :avatar_content_type
  	
  end
end
