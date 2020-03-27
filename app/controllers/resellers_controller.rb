class ResellersController < ApplicationController
  before_action :user_accept_terms_required!

  before_action :admin_tenant_required, only: :destroy
  # GET /resellers
  # GET /resellers.json
  def index
    @resellers = partner_scope

    @filters = {search: params[:search]}

    if @filters[:search].present?
      @resellers = @resellers.where("LOWER(companies.name) LIKE :search", search: "%#{@filters[:search].downcase}%")
    end

    @resellers = @resellers.order(:name).page(params[:page]).per_page(default_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @resellers }
    end
  end

  # GET /resellers/1
  # GET /resellers/1.json
  def show
    @reseller = partner_scope.find(params[:id])
    session['by_reseller'] = 1
    set_breadcrumb
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reseller }
    end
  end

  # GET /resellers/new
  # GET /resellers/new.json
  def new
    @reseller = partner_scope.new
    @reseller.build_location

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reseller }
    end
  end

  # GET /resellers/1/edit
  def edit
    @reseller = partner_scope.find(params[:id])
    @reseller.build_location if !@reseller.location
  end

  def upgrade
    @reseller = partner_scope.find(params[:id])
    @plans = Plan.for_partner
    @invoices = Invoice.where(company_id: @reseller.id)
  end

  def upgrade_plan_request
    @partner = partner_scope.find(params[:id])
    @plan = Plan.find(params[:plan_id])

    return if !@partner || !@plan

    if PlanRequest.upgrade(@partner.id, @plan.id, current_user.id)
      flash[:notice] = I18n.t("upgrade.success")
      redirect_to action: 'upgrade'
    else
      flash[:error] = I18n.t("upgrade.failed")
      redirect_to action: 'upgrade'
    end

  end

  def cancel_plan_request
    @partner = partner_scope.find(params[:id])

    return if !@partner

    if PlanRequest.downgrade(@partner.id)
      redirect_to action: 'upgrade', notice: I18n.t("upgrade.cancelled")
    end

  end

  # POST /resellers
  # POST /resellers.json
  def create
    @reseller = partner_scope.new(reseller_params)
    @reseller.company_type_name = :partner

    #TODO: next - views/tests for reseller creates his own reseller_co
    netcos = Company.default_parent
    if current_company.is_jvp?
      @reseller.parent_id = current_company.id
    else
      @reseller.parent_id = netcos.id
    end

    respond_to do |format|
      if @reseller.save
        CompanyRegisterMailer.send_request(@reseller.id).deliver
        if reseller_params[:plan_id].present?
          PlanRequest.upgrade(@reseller.id, reseller_params[:plan_id], current_user.id, true)
        end

        format.html { redirect_to company_reseller_path(@reseller.parent_id, @reseller), notice: I18n.t('partners.messages.successfully_created') }
        format.json { render json: @reseller, status: :created, location: @reseller }
      else
        format.html { render action: "new" }
        format.json { render json: @reseller.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resellers/1
  # PATCH/PUT /resellers/1.json
  def update
    @reseller = partner_scope.find(params[:id])

    respond_to do |format|
      if params[:company][:avatar] && @reseller.update_attribute(:avatar, params[:company][:avatar])
        format.html { redirect_to company_reseller_path(@reseller.parent_id, @reseller), notice: I18n.t('partners.messages.successfully_updated') }
        format.json { head :no_content }
        format.js #
      elsif @reseller.update_attributes(reseller_params)
        if reseller_params[:plan_id].present?
          PlanRequest.upgrade(@reseller.id, reseller_params[:plan_id], current_user.id, true)
        end
        if reseller_params[:is_dsp].blank?
          @reseller.update_attribute("is_dsp", false)
        else
          @reseller.update_attributes(premium_from: nil, premium_until: nil, plan_id: nil)
        end
        format.html {
          redirect = (session['homes.step'] == 2) ? partner_step3_homes_path : company_reseller_path(@reseller.parent_id, @reseller)
          redirect_to redirect, notice: I18n.t('partners.messages.successfully_updated') 
        }
        format.json { head :no_content }
        format.js #
      else
        format.html { render action: "edit" }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resellers/1
  # DELETE /resellers/1.json
  def destroy
    @reseller = partner_scope.find(params[:id])
    @reseller.destroy

    respond_to do |format|
      format.html { redirect_to company_resellers_url(current_company) }
      format.json { head :no_content }
    end
  end

  private
    def admin_tenant_required
      current_user.is_admin? || current_company.is_jvp? || access_denied!
    end

    def reseller_params
      permit = [:name, :name2, :vat_number, :business_id, :phone, :mobile, :contact_person, :email, :invoice_email, :phone2, :mobile2, :contact_person2, :email2, :url, :remarks, :avatar, :is_dsp, :plan_id, location_attributes: [:id, :latitude, :longitude, :address, :address2, :city, :country, :zip,:_destroy]]
      permit << :is_blocked if current_user.is_admin? || current_company.is_jvp?
      permit += [:premium_from, :premium_until] if current_user.is_admin? || current_company.is_jvp?
      params1 = params.require(:company).permit(*permit)
      params1
    end

    def set_breadcrumb
      session[:breadcrumb] = {key: 'reseller', name: @reseller.name, url: request.path}
    end
end
