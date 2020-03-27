class UserAcceptTerms < ActiveRecord::Migration
  def up
    add_column :users, :accept_terms, :boolean, default: false, null: false
    User.update_all(accept_terms: true)
  end
  def down
    remove_column :users, :accept_terms
  end
end
