class UserInviteEmail < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sent_email, :boolean, default: false
  end
end
