class EvaluationResultsController < ApplicationController
  before_action :check_changes_permitted, except: [:show, :toggle_employee]
  helper_method :current_customer

  def new
    service = Service.find_by_id(params[:service_id]) || Service.order(:code).first
    @evaluation_result = current_evaluation.evaluation_results.new
    @evaluation_result.service = service
    @evaluation_result.evaluation_result_servers.build
    @evaluation_result.evaluation_result_appliances.build
    @evaluation_service = @evaluation.evaluation_services.where(:service_id => @evaluation_result.service_id).first
  end

  def show
    fetch_current_result
    @evaluation_service = @evaluation.evaluation_services.where(:service_id => @evaluation_result.service_id).first
  end

  def edit
    fetch_current_result
    @evaluation_result.evaluation_result_servers.build if @evaluation_result.evaluation_result_servers.empty?
    @evaluation_result.evaluation_result_appliances.build if @evaluation_result.evaluation_result_appliances.empty?
    @evaluation_result.service = Service.find(:first) unless @evaluation_result.service
    @evaluation_service = @evaluation.evaluation_services.where(:service_id => @evaluation_result.service_id).first
  end

  # POST /companies
  # POST /companies.json
  def create
    @evaluation_result = current_evaluation.evaluation_results.new(evaluation_result_params)
    @evaluation_result.created = current_user
    @evaluation_result.updated_by = current_user.id
    @evaluation_result.company_branch_ids = params["evaluation_result"]["evaluation_result_company_branches"].reject!{ |c| !c.present? }

    if params[:links].present? and params[:links].is_a?(Array)
      @evaluation_result.links = params[:links][1..-1].select(&:present?)
    end

    respond_to do |format|
      if @evaluation_result.save
        track_evaluation_update

        format.html { redirect_to customer_evaluation_path(current_customer, current_evaluation), notice: I18n.t('evaluation_results.messages.successfully_created') }
        format.json { render json: @evaluation_result, status: :created, location: @evaluation_result }
      else
        format.html { render action: :new }
        format.json { render json: @evaluation_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def clone
    fetch_current_result
    @cloned_evaluation_result = @evaluation_result.clone_evaluation_result

    redirect_to edit_customer_evaluation_evaluation_result_path(current_customer, current_evaluation, @cloned_evaluation_result), notice: I18n.t('evaluation_results.successfully_cloned')
  end


  def toggle_employee
    fetch_current_result
    @employee = current_evaluation.customer.employees.find(params["employee_id"])
    @employee_evaluation_result = @evaluation_result.employee_evaluation_results.find_or_create_by(employee_id: @employee.id)
    @ordered_employee_evaluations = @evaluation.employee_evaluations.order('employee_evaluations.employee_id desc')
    if @act = EmployeeEvaluationResult::ACTIVITY_TYPES[params[:activity]]
      @employee_evaluation_result.toggle(@act)
      @employee_evaluation_result.save!
    end

    respond_to do |format|
      format.html{ redirect_to customer_evaluation_resources_path(current_customer, current_evaluation) }
      format.js#
    end
  end


  def update
    fetch_current_result
    @evaluation_result.is_edit = true
    @evaluation_result.updated_by = current_user.id
    @evaluation_result.updated_at = Time.now
    @evaluation_result.company_branch_ids = params["evaluation_result"]["evaluation_result_company_branches"].reject!{ |c| !c.present? }

    update_depending(params["evaluation_result"]["result_dependant_services"])
    update_dependant(params["evaluation_result"]["result_depending_services"])

    @erf = []
    if params[:assets]
      params[:assets].each { |asset|
        if @evaluation_result.evaluation_result_files.create(asset: asset)
          @erf << @evaluation_result.evaluation_result_files.last
        end
      }
    end

    if params[:documents]
      params[:documents].each { |document|
        @evaluation_result.evaluation_result_files.create(document: document)
      }
    end
    @documents = @evaluation_result.evaluation_result_files.documents.order(:id)

    if params[:links].present? and params[:links].is_a?(Array)
      @evaluation_result.links = params[:links][1..-1].select{|url| url.present? && url =~ URI::regexp}
    end

    respond_to do |format|
      if @evaluation_result.update_attributes evaluation_result_params
        track_evaluation_update
        if params["next_action"] == 'next'
          fetch_next_result
          if @evaluation_next_result != nil
            format.html { redirect_to edit_customer_evaluation_evaluation_result_path(current_customer, current_evaluation, @evaluation_next_result) }
          end
        else
          format.html { redirect_to customer_evaluation_path(current_customer, current_evaluation), notice: I18n.t('evaluation_results.messages.successfully_updated') }
          format.json { render json: @evaluation_result, status: :created, location: @evaluation_result }
        end
        format.js#
      else
        format.html { format.html { render action: :edit }}
        format.json { render json: @evaluation_result.errors, status: :unprocessable_entity }
        format.js#
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    fetch_current_result
    begin
      @evaluation_result.destroy

      if @evaluation_result.evaluation_service.present?
        @evaluation_result.evaluation_service.update_attribute(:status, EvaluationService::STATUSES.index(:draft))
      end

      @evaluation.update_attributes(:updated_by => current_user.id, :updated_at => Time.now)
      redirect_to customer_evaluation_path(current_customer, current_evaluation), notice: I18n.t('commons.successfully_deleted')
    rescue ActiveRecord::DeleteRestrictionError => e
      redirect_to customer_evaluation_path(current_customer, current_evaluation), alert: e.message
    rescue
      redirect_to customer_evaluation_path(current_customer, current_evaluation), alert: I18n.t('commons.cannot_delete')
    end
  end

  private

  def fetch_current_result
    @evaluation_result = current_evaluation.evaluation_results.find(params[:id]) || nil
  end

  def fetch_next_result
    evaluation_result = ActiveRecord::Base.connection.exec_query(session[:right_service_query])

    next_result_id = 0
    found_next_result = false
    evaluation_result.each do |row|
      next_result_id = row["id"]
      if found_next_result == true
        break
      end

      if row["id"].to_s == params[:id]
        found_next_result = true
      end
    end

    @evaluation_next_result = current_evaluation.evaluation_results.find(next_result_id) || nil
  end

  def current_evaluation
    @evaluation ||= Evaluation.find params[:evaluation_id]
  end

  def current_customer
    @customer ||= Company.find params[:customer_id]
  end

  def evaluation_result_params
    permit = [:company_branch_id, :service_id, :cloud_service, :supplier, :servers_count, :appliances_count, :users_count, :gb_reserved, :gb_used, :service_attributes_info, :capex, :opex, :hours_extern, :hours_intern, :recovery_time, :guaranteed_recovery_time, :impact, :failure_impact_per_day, :future_strategy, :enhancements, :additional_services, :overview]
    permit += [:planned_cloud_service, :planned_supplier, :planned_servers_count, :planned_appliances_count, :planned_users_count, :planned_hours_intern, :planned_hours_extern, :planned_capex, :planned_opex]
    permit += [:assessment_description, :assessment_status, :recommended_measures, :remarks]
    permit += [:distributor, :planned_distributor]
    permit << {assets: [], documents: [], links: []}
    permit << {evaluation_result_servers_attributes: [:id, :name, :details, :os, :gb_reserved, :gb_used, :_destroy]} unless params[:assets] || params[:documents]
    permit << {evaluation_result_appliances_attributes: [:id, :name, :tech_system, :info_details, :_destroy]} unless params[:assets] || params[:documents]
    params.require(:evaluation_result).permit(*permit)
  end

  def check_changes_permitted
    if current_evaluation.is_published?
      if fetch_current_result
        redirect_to customer_evaluation_evaluation_result_path(current_customer, current_evaluation, fetch_current_result)
      else
        redirect_to customer_evaluation_path(current_customer, current_evaluation)
      end
    end
  end

  def track_evaluation_update
    @evaluation.update_attributes(:updated_by => current_user.id, :updated_at => Time.now)
  end

  def update_depending(a)
    if a.kind_of?(Array)
      a.reject!{ |c| !c.present? }
      if a.any?
        @evaluation_result.evaluation_result_service_dependances.where("service_id=? AND service_depending_id NOT IN (?)", @evaluation_result.service, a).each{|d| d.destroy}
        a.each do |sid|
          rds = @evaluation_result.evaluation_result_service_dependances.where(service_id: @evaluation_result.service, service_depending_id: sid).first_or_create
          rds.save!
        end
      else
        @evaluation_result.evaluation_result_service_dependances.where(service_id: @evaluation_result.service).each{|d| d.destroy}
      end
    end
  end

  def update_dependant(a)
    if a.kind_of?(Array)
      a.reject!{ |c| !c.present? }
      if a.any?
        @evaluation_result.evaluation_result_service_dependances.where("service_depending_id=? AND service_id NOT IN (?)", @evaluation_result.service, a).each{|d| d.destroy}
        a.each do |sid|
          rds = @evaluation_result.evaluation_result_service_dependances.where(service_depending_id: @evaluation_result.service, service_id: sid).first_or_create
          rds.save!
        end
      else
        @evaluation_result.evaluation_result_service_dependances.where(service_depending_id: @evaluation_result.service).each{|d| d.destroy}
      end
    end
  end

end
