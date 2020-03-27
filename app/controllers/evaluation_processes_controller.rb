class EvaluationProcessesController < ApplicationController

  before_action :check_changes_permitted, except: :index
  helper_method :current_customer

  def index
    current_evaluation
  end

  def new
    @evaluation_process = @evaluation.evaluation_processes.new()
    completed = @evaluation.evaluation_processes.map(&:work_process_id).compact
    if completed.any?
      @work_options = WorkProcess.where('work_processes.id not in (?)',completed).includes(:translations).with_locales(I18n.locale).map{|a| [a.name, a.id] }
    else
      @work_options = WorkProcess.includes(:translations).with_locales(I18n.locale).map{|a| [a.name, a.id] }
    end
  end

  def edit
    @evaluation_process = @evaluation.evaluation_processes.find(params[:id])
    completed = @evaluation.evaluation_processes.where('evaluation_processes.work_process_id <> ?', @evaluation_process.work_process_id).map(&:work_process_id).compact
    if completed.any?
      @work_options = WorkProcess.where('work_processes.id not in (?)',completed).includes(:translations).with_locales(I18n.locale).map{|a| [a.name, a.id] }
    else
      @work_options = WorkProcess.includes(:translations).with_locales(I18n.locale).map{|a| [a.name, a.id] }
    end
  end

  def update
    @evaluation_process = @evaluation.evaluation_processes.find(params[:id])

    evaluation_result_ids = params['evaluation_process']['evaluation_process_results']
    evaluation_result_ids.delete("")
    @evaluation_process.evaluation_result_ids = evaluation_result_ids

    respond_to do |format|
      if @evaluation_process.update_attributes params_processes
        flash[:notice] = I18n.t('commons.successfully_updated')
        format.html{ redirect_to action: :index}
      else
        format.html{render action: :edit}
      end
    end
  end

  def create
    @evaluation_process = @evaluation.evaluation_processes.new(params_processes)

    evaluation_result_ids = params['evaluation_process']['evaluation_process_results']
    evaluation_result_ids.delete("")
    @evaluation_process.evaluation_result_ids = evaluation_result_ids

    respond_to do |format|
      if @evaluation_process.save
        flash[:notice] = I18n.t('commons.successfully_created')
        format.html{redirect_to action: :index}
      else
        render :new
      end
    end
  end

  def destroy
    @evaluation_process = @evaluation.evaluation_processes.find(params[:id])
    @evaluation_process.destroy
    respond_to do |format|
      flash[:notice] = I18n.t('commons.successfully_deleted')
      format.html { redirect_to action: :index }
      format.js#
    end
  end


  private

    def current_evaluation
      @evaluation = current_customer.customer_evaluations.find(params[:evaluation_id])
    end

    def current_customer
      @customer ||= customer_scope.find params[:customer_id]
    end

    def params_processes
      params.require(:evaluation_process).permit(:evaluation_id, :work_process_id, :evaluation_process_results_attributes => [:evaluation_process_id,:evaluation_result_id])
    end

    def check_changes_permitted
      if current_evaluation.is_published?
        redirect_to customer_evaluation_path(current_customer, current_evaluation)
      end
    end
end
