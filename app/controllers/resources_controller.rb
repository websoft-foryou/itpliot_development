class ResourcesController < ApplicationController
  helper_method :current_customer

  def index
    @evaluation = current_customer.customer_evaluations.find(params[:evaluation_id])
    @domains = Domain.order(:id)
    @ordered_employee_evaluations = @evaluation.employee_evaluations.joins(:employee).order('employee_id desc')
    @ordered_employees = @evaluation.enabled_employees.joins(:employee_evaluations).where("employee_evaluations.evaluation_id=?", params[:evaluation_id]).order('seq asc')

    @progress_bar_step = 1
    @progress_bar_step += 1 if @ordered_employee_evaluations.any?
    @progress_bar_step += 1 if @evaluation.evaluation_results.joins(:employee_evaluation_results).exists?

    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "evaluation_resources", :encoding => 'utf8', layout: 'pdf.html.erb', :orientation => 'Landscape', page_size: 'A3', margin: {top: 10, right: 1, bottom: 10, left: 2}
      end
      format.csv do
        headers["Content-Disposition"] = "attachment;filename=evaluation_resources_#{Date.today.strftime("%b_%d_%Y")}.csv"
        headers["Content-Type"] = "text/csv; charset=ISO-8859-1"
      end
    end

  end


  private

    def current_evaluation
      @evaluation = current_customer.customer_evaluations.find(params[:evaluation_id])
    end

    def current_customer
      @customer ||= customer_scope.find params[:customer_id]
    end

end
