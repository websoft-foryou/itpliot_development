class ServicesController < ApplicationController

  before_action :admin_required!

  # GET /services
  # GET /services.json
  def index
    @services = Service.includes(:translations)
    params[:order] = params[:order] || 'position'
    @filters = {search: params[:search], order: params[:order]}

    if @filters[:search].present?
      @services = @services.with_translations(current_user.locale).where("LOWER(service_translations.name) LIKE :search OR LOWER(services.code) LIKE :search", search: "%#{@filters[:search].downcase}%")
    end

    if @filters[:order] == 'name'
      @services = @services.with_translations(current_user.locale).order("service_translations.name")
    elsif @filters[:order] == 'code'
      @services = @services.order('LENGTH(code), code')
    else
      @services = @services.order("position = 0, position").order('LENGTH(code), code')
    end

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @services }
    end
  end

  # GET /services/1
  # GET /services/1.json
  def show
    @service = Service.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @service.to_json(:include => {:dependings => { :only => [:id, :code] },:inverse_dependings => { :only => [:id, :code] }}) }
    end
  end

  # GET /services/new
  # GET /services/new.json
  def new
    @service = Service.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @service }
    end
  end

  # GET /services/1/edit
  def edit
    @service = Service.find(params[:id])
  end

  # POST /services
  # POST /services.json
  def create
    @service = Service.new(service_params)
    
    respond_to do |format|
      if @service.save
        format.html { redirect_to services_path, notice: I18n.t('commons.successfully_created') }
        format.json { render json: @service, status: :created, location: @service }
      else
        format.html { render action: "new" }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1
  # PATCH/PUT /services/1.json
  def update
    @service = Service.find(params[:id])

    update_depending(params["service"]["dependings"])
    update_dependant(params["service"]["inverse_dependings"])

    respond_to do |format|
      if @service.update_attributes(service_params)
        format.html { redirect_to services_path(:anchor => "service_anchor_#{@service.id}"), notice: I18n.t('commons.successfully_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def sort_all
    params[:service].each_with_index do |id, index|
        Service.where(id: id).update_all(position: index+1)
    end
    head :no_content
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service = Service.find(params[:id])
    # @service.destroy

    respond_to do |format|
      #if @service.destroyed?
      if @service.update_attribute(:is_disp, false)
        format.html { redirect_to services_path, notice: I18n.t('commons.successfully_deleted') }
        format.json { head :no_content }
      else
        format.html { redirect_to services_path, alert: @service.errors.full_messages.first }
        format.json { head :no_content }
      end
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def service_params
      params.require(:service).permit(:code, :owner_id, :position, :is_disp, :translations_attributes => [:id, :locale, :name, :purpose, :product_examples])
    end

    def update_depending(a)
      if a.kind_of?(Array)
        a.reject!{ |c| !c.present? }
        if a.any?
          @service.service_dependances.where("depending_id NOT IN (?)",a).each{|d| d.destroy}
          a.each do |sid|
            rds = @service.service_dependances.where(depending_id: sid).first_or_create
            rds.save!
          end
        else
          @service.service_dependances.each{|d| d.destroy}
        end
      end
    end

    def update_dependant(a)
      if a.kind_of?(Array)
        a.reject!{ |c| !c.present? }
        if a.any?
          @service.inverse_service_dependances.where("service_id NOT IN (?)",a).each{|d| d.destroy}
          a.each do |sid|
            rds = @service.inverse_service_dependances.where(service_id: sid).first_or_create
            rds.save!
          end
        else
          @service.inverse_service_dependances.each{|d| d.destroy}
        end
      end
    end

  protected

    def admin_required!
      current_user.is_admin? or access_denied!
    end
end
