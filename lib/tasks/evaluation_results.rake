namespace :evaluation_results do

  task check_results_referencies: :environment do
    EvaluationResult.find_each do |result|
      unless result.evaluation.evaluation_services.find_by_service_id(result.service.id)
        puts "result_id=#{result.id} evaluation=#{result.evaluation.id} #{result.evaluation.name}"
      end
    end
  end

  task missing_ev_results: :environment do
    evaluation_services = EvaluationService.active.where("evaluation_services.service_id NOT IN (SELECT service_id FROM evaluation_results where evaluation_id=evaluation_services.evaluation_id)")

    if ENV["EVALUATION_ID"].present?
      evaluation_services = evaluation_services.where(evaluation_id: ENV["EVALUATION_ID"].to_i)
    end

    current_user = User.where(id: 34).first || User.admin.first

    evaluation_services.each.with_index do |es, index|
      first_branch = es.evaluation.customer.company_branches.first
      next if first_branch.blank?
      EvaluationResult.where(evaluation_id: es.evaluation_id, service_id: es.service_id, company_branch_id: first_branch.id).first_or_create do |er|
        er.created = current_user
        er.updated_by = current_user.id
      end
      puts "Created: #{index + 1} evaluation_results"
    end

  end

end
