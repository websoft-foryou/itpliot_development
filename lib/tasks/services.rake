namespace :services do

  task update_positions: :environment do
    require 'csv'

    csv_text = File.read(Rails.root.join('lib', 'seeds', 'services_positions.csv'))
    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ";")
    csv.each do |row|
      params = row.to_hash
      puts params.inspect
      service = Service.find_by_code(params["code"])
      if service
        service.position = params["position"]
          if service.valid?
            puts "SAVED #{service.code}"
            # service.save!
          else
            puts "NOT VALID #{service.inspect} #{service.errors.inspect}"
          end
      else
        puts "==SERVICE #{params["code"]} NOT FOUND=="
      end

        puts '---'
    end
  end

  task import_csv_services: :environment do
    require 'csv'

    csv_text = File.read(Rails.root.join('lib', 'seeds', 'services_reference1.csv'))
    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ";")
    csv.each do |row|
      params = row.to_hash
      service = Service.find_or_initialize_by_code(params["code"])
      service.attributes = params
        if service.valid?
          puts "SAVED #{service.code}"
          #service.save!
        else
          puts "NOT VALID #{service.inspect} #{service.errors.inspect}"
        end
        puts '---'
    end
  end

  task import_dependencies: :environment do
    require 'csv'

    csv_text = File.read(Rails.root.join('lib', 'seeds', 'service_dependencies.csv'))
    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ";")
    csv.each do |row|
      params = row.to_hash
      service = Service.find_by_code(params["code"])
        if service
          puts "SERVICE #{service.code}"
          scodes = []
          (1..8).each do |n|
            scodes << params["n#{n}"] if params["n#{n}"].present?
          end
        if scodes.any?
          puts "scodes: #{scodes}"
          sids = Service.where(code: scodes).map(&:id)
          puts "sids: #{sids}"
          if sids.any?
            puts 'delete some'
            service.service_dependances.where("depending_id NOT IN (?)",sids).each{|d| d.destroy}
                puts 'add some'
                sids.each do |sid|
                  rds = service.service_dependances.where(depending_id: sid).first_or_create
                  #rds.save!
                end
          end
        else
          service.service_dependances.each{|d| d.destroy}
        end

          puts scodes
          #service.save!
        else
          puts "NOT VALID #{service.inspect} #{service.errors.inspect}"
        end
        puts '---'
    end
  end

end
