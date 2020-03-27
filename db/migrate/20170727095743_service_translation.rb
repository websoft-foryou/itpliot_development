class ServiceTranslation < ActiveRecord::Migration
  def change
  	add_column :services, :name, :string
  	Service.update_all("name = name_en")
  	#Service.connection.execute("update services set name = name_en")
  end

end
