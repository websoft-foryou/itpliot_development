namespace :evaluations do

  task delete_draft_services_for_published: :environment do
    #clean draft services after bug fix on check_new_services
    Evaluation.published.order(:customer_id).each do |e|
      draft_es = e.evaluation_services.where(status: EvaluationService::STATUSES.index(:draft))
      if draft_es.count > 0
        puts "Evaluation #{e.id}/#{e.customer_id} #{e.name} has draft services: #{draft_es.count}"
        draft_es.delete_all
        puts '---'
      end
    end
  end

  task update_active_evaluation_services: :environment do
    active_status = EvaluationService::STATUSES.index(:active)
    Evaluation.find_each do |evaluation|
      evaluation_services = evaluation.evaluation_services

      puts "#{evaluation.id} #{evaluation.name}"
      puts "active: #{evaluation_services.active.size} ignored: #{evaluation_services.ignored.size} deactivated: #{evaluation_services.deactivated.size}"

      count_new = 0
      Service.order(:position).each do |service|
        es = evaluation_services.find_or_initialize_by_service_id(service.id)
        es.position = service.position
        if es.new_record?
          es.status = 2
          count_new += 1
        end
        es.save!
      end
      puts "active: #{evaluation_services.active.size} ignored: #{evaluation_services.ignored.size} deactivated: #{evaluation_services.deactivated.size}"
      puts "new added: #{count_new}"
      puts "---------------"
    end

  end

end
