class EvaluationServicesController < ApplicationController
  helper_method :current_customer


  def index
    @evaluation_services = fetch_evaluation_services

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @evaluations }
    end
  end

  def update
    @evaluation = current_customer.customer_evaluations.find(params[:evaluation_id])
    if @evaluation.is_draft?
      @evaluation_service = @evaluation.evaluation_services.find(params[:id])
      @evaluation_service.update_attributes(evaluation_service_params)
    end
    respond_to do |format|
      format.html{ redirect_to customer_evaluation_path(current_customer, @evaluation) }
      format.js#
    end
  end


  private

    def evaluation_service_params
      params.permit(:position, :status)
    end

    def current_customer
      @customer ||= customer_scope.find params[:customer_id]
    end

    def check_new_services
      new_added_services = Service.where("id not in (?)", @evaluation.evaluation_services.pluck(:service_id))
      if new_added_services.any?
        new_added_services.each do |s|
          @evaluation.evaluation_services.build(service_id: s.id, position: s.position, status: EvaluationService::STATUSES.index(:active))
        end
        @evaluation.save!
      end
    end


    def fetch_evaluation_services
      @evaluation = current_customer.customer_evaluations.find(params[:evaluation_id])
      check_new_services
      evaluation_services = @evaluation.evaluation_services.joins(:service)
      params[:order] = params[:order] || 'position'
      @filters = {search: params[:search], order: params[:order], filter: params[:filter]}

      if @filters[:search].present?
        evaluation_services = evaluation_services.
                              joins('INNER JOIN service_translations ON service_translations.service_id = evaluation_services.service_id').
                              where('service_translations.locale=?',I18n.locale.to_s).
                              where("LOWER(service_translations.name) LIKE :search OR LOWER(services.code) LIKE :search OR LOWER(service_translations.purpose) LIKE :search ", search: "%#{@filters[:search].downcase}%")
      end
      if @filters[:order] == 'name'
        evaluation_services = evaluation_services.
                              joins('INNER JOIN service_translations ON service_translations.service_id = evaluation_services.service_id').
                              where('service_translations.locale=?',I18n.locale.to_s).
                              order("service_translations.name")
      elsif @filters[:order] == 'code'
        evaluation_services = evaluation_services.order('services.code')
      else
        evaluation_services = evaluation_services.order('evaluation_services.position')
      end


      if @filters[:filter].present?
        attribute, value = @filters[:filter].split(':')

        evaluation_services = case attribute
        when 'status'
          evaluation_services.where('evaluation_services.status=:status', status: value)
        when 'theme'
          evaluation_services.joins(service: :theme_services).where('theme_services.theme_id=:theme_id', theme_id: value)
        when 'industry'
          evaluation_services.joins(service: :industry_services).where('industry_services.industry_id=:industry_id', industry_id: value)
        else
          scoped
        end
      end

      evaluation_services
    end
end
