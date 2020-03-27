class CompaniesController < ApplicationController
  before_action :user_accept_terms_required!
  # before_action :admin_required!

  def switch
    session['app.current_company'] = params[:id]
    redirect_to root_path()
  end


  # GET /companies
  # GET /companies.json
  def index
    @companies = companies_scope

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @companies }
    end
  end

  # GET /companies/new
  # GET /companies/new.json
  def new
    @company = companies_scope.new
    @company.build_location
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @company }
    end
  end

  def show
    @company = companies_scope.find(params[:id])
    set_breadcrumb
  end

  # GET /companies/1/edit
  def edit
    @company = companies_scope.find(params[:id])
    @company.build_location if !@company.location.present?
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = companies_scope.new(company_params)

    respond_to do |format|
      if @company.save
        CompanyRegisterMailer.send_request(@company.id).deliver

        flash.now[:notice] = I18n.t('commons.successfully_created')
        format.html { render action: "show" }
        format.json { render json: @company, status: :created, location: @company.location }
        format.js #
      else
        format.html { render action: "new" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
        format.js #
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    @company = companies_scope.find(params[:id])

    respond_to do |format|
      if @company.update_attributes(company_params)
        format.html { redirect_to @company, notice: I18n.t('commons.successfully_updated') }
        format.json { head :no_content }
        format.js #
      else
        format.html { render action: "edit" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company = companies_scope.find(params[:id])

    respond_to do |format|
      format.html {
        if @company.destroy
          redirect_to companies_url, notice: I18n.t('commons.successfully_deleted')
        else
          redirect_to companies_url, alert: @company.errors.full_messages.first
        end
      }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def company_params
      params.require(:company).permit(:name, :name2, :vat_number, :business_id, :phone, :mobile, :contact_person, :email, :phone2, :mobile2, :contact_person2, :email2, :url, :remarks, :avatar, location_attributes: [:id, :latitude, :longitude, :address, :address2, :city, :country, :zip,:_destroy] )
    end

    def set_breadcrumb
      session[:breadcrumb] = {key: 'company', name: @company.name, url: request.path}
    end

  protected

    def admin_required!
      current_user.is_admin? or access_denied!
    end
end
