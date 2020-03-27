namespace :businesses do

	task import_csv: :environment do
		require 'csv'

		csv_text = File.read(Rails.root.join('lib', 'seeds', 'businesses.csv'))
		csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ";")
		csv.each do |row|
			params = row.to_hash
			obj = Business.find_or_initialize_by_name_en(params["name_en"])
			puts "obj #{obj.inspect}"
			obj.attributes = params
			puts "obj #{obj.inspect}" 
  			if obj.valid?
  				puts "SAVED #{obj.name_en}"
  				# obj.save!
  			else
  				puts "NOT VALID #{obj.inspect} #{obj.errors.inspect}"
  			end
  			puts '---'
		end
	end
end