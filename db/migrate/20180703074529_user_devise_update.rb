class UserDeviseUpdate < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :invitation_created_at, :datetime
    add_column :users, :short_token, :string
    change_column :users, :invitation_token, :string, :limit => 255
  end

  def down
    remove_column :users, :invitation_created_at
  end
end