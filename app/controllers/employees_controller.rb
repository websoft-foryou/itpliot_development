class EmployeesController < ApplicationController

  helper_method :current_customer

  def update
    @employee = current_customer.employees.find(params[:id])
    redirect = customer_evaluation_resources_path(current_customer, params[:evaluation_id])
    respond_to do |format|
        if @employee.update_attributes(employee_params)
          ee = @employee.employee_evaluations.where(evaluation_id: params[:evaluation_id]).first_or_create
          ee.update_attributes(employee_first_name: @employee.current_first_name, employee_last_name: @employee.current_last_name, employee_work_type: @employee.current_work_type, employee_monthly_hours: @employee.current_monthly_hours)
          format.html { redirect_to redirect, notice: I18n.t('commons.successfully_updated') }
          format.js
        else
          format.html { redirect_to redirect, notice: I18n.t('commons.prevent_save_error.other') }
          format.js
        end
      end
  end

  def toggle_employee_domain
    @employee = current_customer.employees.find(params[:id])
    test_employee_domain = @employee.employee_domains.where(domain_id: params["domain_id"], evaluation_id: params["evaluation_id"]).first
    if test_employee_domain
      test_employee_domain.destroy
    else
      @employee_domain = @employee.employee_domains.new(domain_id: params["domain_id"], evaluation_id: params["evaluation_id"])
      @employee_domain.save!
    end

    respond_to do |format|
      format.html { redirect_to customer_evaluation_resources_path(current_customer, params[:evaluation_id]) }
    end
  end

  def change_order
    employee = current_customer.employees.find(params[:id])
    seq = employee.seq
    type = params[:type]

    if type == 'down'
      next_employee = current_customer.employees.where('seq > ?', seq).order('seq asc').first
      next_seq = next_employee.seq
      employee.seq = next_seq
      next_employee.seq = seq
      employee.save!
      next_employee.save!
    elsif type == 'up'
      prev_employee = current_customer.employees.where('seq < ?', seq).order('seq asc').last
      prev_seq = prev_employee.seq
      employee.seq = prev_seq
      prev_employee.seq = seq
      employee.save!
      prev_employee.save!
    end

    @evaluation = current_customer.customer_evaluations.find(params[:evaluation_id])
    @domains = Domain.order(:id)
    @ordered_employee_evaluations = @evaluation.employee_evaluations.joins(:employee).order('employee_id desc')
    @ordered_employees = @evaluation.enabled_employees.joins(:employee_evaluations).where("employee_evaluations.evaluation_id=?", params[:evaluation_id]).order('seq asc')

    respond_to do |format|
      format.js
    end

  end

  def create
    @employee = current_customer.employees.new(employee_params)
    if @employee.save
      ee = @employee.employee_evaluations.where(evaluation_id: params[:evaluation_id]).first_or_create
      ee.update_attributes(employee_first_name: @employee.current_first_name, employee_last_name: @employee.current_last_name, employee_work_type: @employee.current_work_type, employee_monthly_hours: @employee.current_monthly_hours)
    end
    redirect_to customer_evaluation_resources_path(current_customer, params[:evaluation_id])
  end

  def destroy
    @employee = current_customer.employees.find(params[:id])
    @employee.disable
    respond_to do |format|
      redirect = customer_evaluation_resources_path(current_customer, params[:evaluation_id])
      format.html { redirect_to redirect, notice: notice }
      format.json { head :no_content }
    end
   end


  private

    def employee_params
      params.require(:employee).permit(:current_first_name, :current_last_name, :current_monthly_hours, :current_work_type)
    end

    def current_customer
      @customer ||= customer_scope.find params[:customer_id]
    end


end
