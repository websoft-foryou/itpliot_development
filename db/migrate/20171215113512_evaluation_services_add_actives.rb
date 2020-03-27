class EvaluationServicesAddActives < ActiveRecord::Migration
  def up
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

  def down
    EvaluationService.where(status: EvaluationService::STATUSES.index(:active)).destroy_all
  end
end
