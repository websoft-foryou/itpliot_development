namespace :evaluation_services do

  task add_evaluation_dependancies: :environment do

    EvaluationService.active.order(:evaluation_id).each do |es|
      puts "id=#{es.id} status=#{es.status} is_active=#{es.is_active?}"
        es.update_attribute(:status, 0)
        es.update_attribute(:status, 2)
        es.save!
    end

  end


end
