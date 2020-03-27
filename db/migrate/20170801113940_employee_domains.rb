class EmployeeDomains < ActiveRecord::Migration
  def change

  	create_table :domains do |t|
  		t.string :code
  		t.string :name
  	end
  	create_table :employee_domains do |t|
  		t.integer :employee_id
  		t.integer :domain_id
  	end

  	opt = {
		"E"=>"Evaluation and Planning",
		"T"=>"Test",
		"O"=>"Order Management",
		"V"=>"Vendor Management",
		"I"=>"Instalation",
		"C"=>"Configuration",
		"A"=>"Administration",
		"M"=>"Monitoring",
		"U"=>"Updates",
		"L1"=>"Level 1 Support",
		"L2"=>"Level 2 Support",
		"L3"=>"Level 3 Support"
  	}



	opt.each do |k,v|
		d = Domain.new(code: "#{k}",name: "#{v}")
		d.save!
	end

  end
end
