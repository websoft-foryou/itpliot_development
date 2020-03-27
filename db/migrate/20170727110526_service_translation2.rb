class ServiceTranslation2 < ActiveRecord::Migration
  def up
  	Service.create_translation_table! :name => :string
  end

  def down
  	Service.drop_translation_table!
  end
end
