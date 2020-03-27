class SetClonedIndexValueToEvaluationService2 < ActiveRecord::Migration[5.2]
  def change
    EvaluationResult.where("cloned_index != '' AND cloned_index != '.01'").each do |er|
      es = EvaluationService.where("evaluation_id=?", er.evaluation_id).order(:position).last
      EvaluationService.create(evaluation_id: er.evaluation_id, service_id: er.service_id, status: er.service_status, position: es.position + 1, cloned_index: er.cloned_index)
    end
  end
end
