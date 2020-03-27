class CustomerBranchesController < ApplicationController
  before_action :user_accept_terms_required!

  def index
    @customer_branches = current_customer.company_branches.order(:id)
  end

  def show
    @customer_branch = current_customer.company_branches.find(params[:id])
  end

  def edit
    @customer_branch = current_customer.company_branches.find(params[:id])
  end

  def new
    @customer_branch = current_customer.company_branches.new
  end

  def update
    @customer_branch = current_customer.company_branches.find(params[:id])
    respond_to do |format|
      if @customer_branch.update_attributes(company_params)
        redirect = if current_company.is_customer? && params[:return_to_service_sets]
          customer_evaluations_path(current_customer)
        else
          customer_customer_branches_path(current_customer)
        end
        format.html { redirect_to redirect, notice: I18n.t('branches.messages.location_successfully_updated') }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # POST /companies
  # POST /companies.json
  def create
    @customer_branch = current_customer.company_branches.new(company_params)

    respond_to do |format|
      if @customer_branch.save
        format.html { 
          redirect = customer_path(current_customer)
          if current_company.is_customer?
            if params[:return_to_service_sets]
              redirect = customer_evaluations_path(current_customer)
            else
              redirect = customer_customer_branches_path(current_customer)
            end
          end
          redirect = company_reseller_customer_path(current_company, current_customer.parent, current_customer) if session[:by_reseller] && current_customer.parent && current_customer.parent.is_partner?
          redirect_to redirect, notice: I18n.t('branches.messages.location_successfully_added') 
        }
        format.json { render json: @customer_branch, status: :created, location: @customer_branch }
        format.js#
      else
        format.html { render :new }
        format.json { render json: @customer_branch.errors, status: :unprocessable_entity }
        format.js#
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @customer_branch = current_customer.company_branches.find(params[:id])

    begin
      @customer_branch.update_attribute(:deleted, true)
      redirect_to customer_customer_branches_path(current_customer), notice: I18n.t('commons.successfully_deleted')
    rescue ActiveRecord::DeleteRestrictionError => e
      redirect_to customer_path(current_customer), notice: e.message
    rescue
      redirect_to customer_customer_branches_path(current_customer), alert: I18n.t('commons.cannot_delete')
    end
  end

  private

    def current_customer
      @customer ||= customer_scope.find params[:customer_id]
    end

    def company_params
      params.require(:company_branch).permit(:name, :description, location_attributes: [:id, :latitude, :longitude, :address, :country, :city, :zip] )
    end
end
