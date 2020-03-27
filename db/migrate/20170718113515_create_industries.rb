class CreateIndustries < ActiveRecord::Migration
  class Industry < ActiveRecord::Base
  end

  def change
  	create_table :industries do |t|
  		t.string :name
  		t.string :name_de
  	end

	opt = [
		"Aerospace and Defense",
		"Automotive",
		"Banking",
		"Consumer Products",
		"Engineering, Construction & Ops.",
		"Health Care",
		"High Tech",
		"Higher Education & Research",
		"Chemicals",
		"Industrial Machinery & Components",
		"Insurance",
		"Life Sciences",
		"Media",
		"Mill Products",
		"Mining",
		"Oil & Gas",
		"Professional Services",
		"Public Sector",
		"Retail",
		"Security & Defense",
		"Sports & Entertainment",
		"Telecommunications",
		"Transportation & Logistics",
		"Utilities",
		"Wholesale Distribution"
	]

	opt.each do |n|
		inds = Industry.new(name: "#{n}", name_de: "#{n}")
		inds.save!
	end

  end
end
