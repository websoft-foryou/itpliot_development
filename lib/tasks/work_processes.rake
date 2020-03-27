namespace :work_processes do

	task import_csv: :environment do
		require 'csv'

		csv_text = File.read(Rails.root.join('lib', 'seeds', 'processes.csv'))
		csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ";")
		csv.each do |row|
			params = row.to_hash

			test = WorkProcess.find_by_name(params['name_en'])

			if test
				obj = test
			else
				obj = WorkProcess.new
			end
			
  			obj.attributes = {locale: :en, name: "#{params['name_en']}"}
  			obj.save!
  			obj.attributes = {locale: :de, name: "#{params['name_de']}"}
  			obj.save!


  			puts '---'
		end
	end
end