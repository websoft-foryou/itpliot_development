class DeleteNameFromThemes < ActiveRecord::Migration
  def up
    rename_column :themes, :name, :name_tmp
    rename_column :themes, :name_de, :name_de_tmp
  end

  def down
    rename_column :themes, :name_tmp, :name
    rename_column :themes, :name_de_tmp, :name_de
  end
end
