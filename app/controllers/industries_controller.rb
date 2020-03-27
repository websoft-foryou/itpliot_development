class IndustriesController < ApplicationController

  before_action :admin_required!, except: [:eval_services_options]

  # GET /industries
  # GET /industries.json
  def index
    @industries = Industry.order(:short_name_en)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @industries }
    end
  end

  # GET /industries/1
  # GET /industries/1.json
  def show
    @industry = Industry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @industry }
    end
  end

  def eval_services_options
    @industry = Industry.find(params[:id])
    services = Service.select('id, code, name')
    services = services.where(id: @industry.industry_services.map(&:service_id))

    respond_to do |format|
      format.json { render json: services }
    end
  end

  # GET /industries/new
  # GET /industries/new.json
  def new
  @industry = Industry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @industry }
    end
  end

  # GET /industries/1/edit
  def edit
    @industry = Industry.find(params[:id])
  end

  # POST /industries
  # POST /industries.json
  def create
    @industry = Industry.new(industry_params)
    respond_to do |format|
      if @industry.save
        format.html { redirect_to industries_path, notice: I18n.t('commons.successfully_created') }
        format.json { render json: @industry, status: :created, location: @industry }
      else
        format.html { render action: "new" }
        format.json { render json: @industry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /industries/1
  # PATCH/PUT /industries/1.json
  def update
    @industry = Industry.find(params[:id])

    if a = params["industry"]["industry_services"]
        a.reject!{ |c| c.empty? }
        if a.any?
          @industry.industry_services.where("service_id NOT IN (?)",a).each{|d| d.destroy}
          a.each do |sid|
            rds = @industry.industry_services.where(service_id: sid).first_or_create
            rds.save!
          end
        else
          @industry.industry_services.each{|d| d.destroy}
        end
      end

    respond_to do |format|
      if @industry.update_attributes(industry_params)
        format.html { redirect_to industries_path, notice: I18n.t('commons.successfully_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @industry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /industries/1
  # DELETE /industries/1.json
  def destroy
    @industry = Industry.find(params[:id])
    @industry.destroy

    respond_to do |format|
      format.html { redirect_to industries_url, notice: I18n.t('commons.successfully_deleted') }
      format.js#
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def industry_params
      params.require(:industry).permit(:name, :name_de, :short_name_en, :short_name_de)
    end

  protected

    def admin_required!
      current_user.is_admin? or access_denied!
    end
end
