class CopyServiceDependencesForExistingServiceSet < ActiveRecord::Migration[5.2]
  def change
    EvaluationResult.all.each do |er|
      er.service.dependings.all.each do |service|
        sd = er.evaluation_result_service_dependances.where(service_id: er.service, service_depending_id: service).first_or_create
        sd.save!
      end

      er.service.inverse_dependings.all.each do |service|
        sd = er.evaluation_result_service_dependances.where(service_id: service, service_depending_id: er.service).first_or_create
        sd.save!
      end
    end
  end
end
