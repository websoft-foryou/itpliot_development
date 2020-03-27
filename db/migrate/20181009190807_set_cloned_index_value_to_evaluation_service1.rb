class SetClonedIndexValueToEvaluationService1 < ActiveRecord::Migration[5.2]
  def change
    EvaluationService.all.each do |es|
      es.cloned_index = ''
      er = EvaluationResult.where("evaluation_id=? AND service_id=?", es.evaluation_id, es.service_id).order(:cloned_index).first
      es.cloned_index = er.cloned_index if er
      es.save!
    end
  end
end
