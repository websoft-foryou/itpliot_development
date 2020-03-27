class ChangeProfileTypeToRoleTypeAndRemoveIsAdminFieldFromUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :profile_type, :role_type

    User.all.each do |u|
      u.role_type = User::ROLE_TYPES.index(:admin) if u.is_admin?
      u.save!
    end

    remove_column :users, :is_admin
  end
end
