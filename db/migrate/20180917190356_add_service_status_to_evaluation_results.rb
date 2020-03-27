class AddServiceStatusToEvaluationResults < ActiveRecord::Migration[5.2]
  def up
    add_column :evaluation_results, :service_status, :integer
    EvaluationService.all.each do |es|
      if es.status == EvaluationService::STATUSES.index(:active) || es.status == EvaluationService::STATUSES.index(:ignored)
        EvaluationResult.where("evaluation_id=? AND service_id=?", es.evaluation_id, es.service_id).each do |er|
          er.service_status = es.status
          er.save(:validate => false)
        end
      end
    end
  end

  def down
    remove_column :evaluation_results, :service_status
  end
end
