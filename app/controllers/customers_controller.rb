class CustomersController < ApplicationController

  before_action :user_accept_terms_required!

  before_action :user_up_customer_required!, except: [:edit,:update, :show, :upgrade, :upgrade_plan_request, :cancel_plan_request]


  # GET /customers
  # GET /customers.json
  def index
    @customers = customer_scope
    session['by_reseller'] = nil

    @filters = {search: params[:search]}

    if @filters[:search].present?
      @customers = @customers.where("LOWER(companies.name) LIKE :search", search: "%#{@filters[:search].downcase}%")
    end

    @customers = @customers.order(:name).page(params[:page]).per_page(default_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @customers }
    end
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @customer = customer_scope.find(params[:id])
    @evaluations = @customer.customer_evaluations.order('evaluations.id desc')
    set_breadcrumb
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.json
  def new
    @customer = customer_scope.new
    @customer.parent_id = params[:reseller_id]
    @customer.build_location

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @customer }
    end
  end

  # GET /customers/1/edit
  def edit

    @customer = customer_scope.find(params[:id])
    unless @customer.parent.is_partner?
      #@customer.parent_id = @customer.parent.children.partner.first.id
    end
      @customer.build_location if !@customer.location
  end

  def upgrade
    @customer = customer_scope.find(params[:id])
    @plans = Plan.for_customer
    @invoices = Invoice.where(company_id: @customer.id)
  end

  def upgrade_plan_request
    @customer = customer_scope.find(params[:id])
    @plan = Plan.find(params[:plan_id])

    return if !@customer || !@plan

    upgrade_result = PlanRequest.upgrade(@customer.id, @plan.id, current_user.id)
    if upgrade_result == 'saving company ok'
      if !@customer.is_direct_customer?
        # https://medialineeurotradesrl.eu.teamwork.com/#tasks/13651334?c=6427552
        # - Addional: When a Customer of a partner choose a self paying subscription the company will automaticly new assigned to the direct selling partner company of his JVP (or better of the JVP of his old partner).
        @customer.update_attribute(:parent_id, first_dsp(@customer).id)
      end
      flash[:notice] = I18n.t("upgrade.success")
      redirect_to action: 'upgrade'
    elsif upgrade_result == 'invoicing failure'
      flash[:error] = I18n.t("upgrade.invoicing_failed")
      redirect_to action: 'upgrade'
    else
      flash[:error] = I18n.t("upgrade.failed")
      redirect_to action: 'upgrade'
    end
  end

  def cancel_plan_request
    @customer = customer_scope.find(params[:id])

    return if !@customer

    if PlanRequest.downgrade(@customer.id)
      redirect_to action: 'upgrade', notice: I18n.t("upgrade.cancelled")
    end

  end

  def set_as_sample
    return if !current_user.is_admin
    @customer = customer_scope.find(params[:id])

    Company.customer.all.each do |c|
      c.update_attribute(:is_sample, false)
    end
    @customer.update_attribute(:is_sample, true)
    redirect_to customer_path(@customer)
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = customer_scope.new(customer_params)
    @customer.company_type_name = :customer

    puts ">>>>> Customer params"
    puts customer_params.inspect

    respond_to do |format|
      if @customer.save
        CompanyRegisterMailer.send_request(@customer.id).deliver
        if customer_params[:plan_id].present?
          PlanRequest.upgrade(@customer.id, customer_params[:plan_id], current_user.id, true)
        end

        format.html {
          redirect = customer_path(@customer)
          redirect = company_reseller_path(current_company, @customer.parent_id) if params[:reseller_id]
          redirect = root_path() if params[:registration]
          redirect_to redirect, notice: I18n.t('customers.successfully_created')
        }
        format.json { render json: @customer, status: :created, location: @customer }
      else
        format.html { render action: "new" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    @customer = customer_scope.find(params[:id])

    respond_to do |format|
      if params[:company][:avatar] && @customer.update_attribute(:avatar, params[:company][:avatar])
        format.html { render action: "edit" }
        format.js #
      elsif @customer.update_attributes(customer_params)
        if customer_params[:plan_id].present?
          PlanRequest.upgrade(@customer.id, customer_params[:plan_id], current_user.id, true)
        end
        format.html {
          redirect = customer_path(@customer)
          redirect = root_path if current_company.is_customer?
          redirect = company_reseller_path(current_company, @customer.parent_id) if params[:reseller_id]
          redirect = company_reseller_customer_path(current_company, @customer.parent_id, @customer) if session[:by_reseller] && @customer.parent && @customer.parent.is_partner?
          redirect = step3_homes_path if session['homes.step'] == 2
          redirect_to redirect, notice: I18n.t('commons.successfully_updated')
        }
        format.json { head :no_content }
        format.js #
      else
        format.html { render action: "edit" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer = customer_scope.find(params[:id])

    redirect = current_company && company_customers_path(current_company) || customers_url
    begin
      @customer.destroy
      redirect_to redirect, notice: I18n.t('commons.successfully_deleted')
    rescue ActiveRecord::DeleteRestrictionError => e
      redirect_to redirect, notice: e.message
    rescue
      redirect_to redirect, alert: I18n.t('commons.cannot_delete')
    end

  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def customer_params
      permit = [:name, :name2, :vat_number, :business_id, :phone, :mobile, :contact_person, :email, :invoice_email, :phone2, :mobile2, :contact_person2, :email2, :url, :remarks, :avatar, :plan_id, location_attributes: [:id, :latitude, :longitude, :address, :address2, :city, :country, :zip,:_destroy]]
      permit << :parent_id if current_user.is_admin? || current_company.is_jvp? # reseller already checked params[:action] == "create"
      permit << :is_blocked if current_user.is_admin? || current_company.is_jvp? # reseller already checked params[:action] == "create"
      permit += [:premium_from, :premium_until] if current_user.is_admin? || current_company.is_jvp? || current_company.is_partner?
      params.require(:company).permit(*permit)
    end

    def user_up_customer_required!
      (current_user.is_admin? or current_company.is_jvp? or current_company.is_partner?) or access_denied!
    end

    def set_breadcrumb
      session[:breadcrumb] = {key: 'customer', name: @customer.name, url: request.path}
    end


    def root(c)
      return c.parent if c.parent.parent_id.blank?

      return root(c.parent)
    end

    def first_dsp(c)
      root_comp = root(c)
      dsp_comp = Company.where("parent_id=? AND company_type=2 AND is_dsp=true", root_comp.id).first
      return dsp_comp unless dsp_comp == nil
      return root_comp
    end
end
