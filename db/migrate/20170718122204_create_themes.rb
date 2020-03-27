class CreateThemes < ActiveRecord::Migration
  class Theme < ActiveRecord::Base
  end

  def change
  	create_table :themes do |t|
  		t.string :name
  		t.string :name_de
  	end
  	opt = [
		"Hardware",
		"Software",
		"Licences"
	]
	opt.each do |n|
		th = Theme.new(name: "#{n}", name_de: "#{n}")
		th.save!
	end
  end
end
