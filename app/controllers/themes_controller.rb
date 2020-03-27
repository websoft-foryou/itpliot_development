class ThemesController < ApplicationController

  before_action :admin_required!, except: [:eval_services_options]

  # GET /themes
  # GET /themes.json
  def index
    @themes = Theme.all
    @themes = Theme.includes(:translations).with_locales(I18n.locale).order('theme_translations.name')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @themes }
    end
  end

  # GET /themes/1
  # GET /themes/1.json
  def show
  @theme = Theme.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @theme }
    end
  end

  def eval_services_options
    @theme = Theme.find(params[:id])
    services = Service.select('id, code, name')
    services = services.where(id: @theme.theme_services.map(&:service_id))

    respond_to do |format|
      format.json { render json: services }
    end
  end

  # GET /themes/new
  # GET /themes/new.json
  def new
  @theme = Theme.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @theme }
    end
  end

  # GET /themes/1/edit
  def edit
    @theme = Theme.find(params[:id])
  end

  # POST /themes
  # POST /themes.json
  def create
    @theme = Theme.new(theme_params)
    @theme.service_ids = params["theme"]["theme_services"].reject!{ |c| !c.present? }
    respond_to do |format|
      if @theme.save
        format.html { redirect_to themes_path, notice: I18n.t('commons.successfully_created') }
        format.json { render json: @theme, status: :created, location: @theme }
      else
        format.html { render action: "new" }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /themes/1
  # PATCH/PUT /themes/1.json
  def update
    @theme = Theme.find(params[:id])
    @theme.service_ids = params["theme"]["theme_services"].reject!{ |c| !c.present? }
    respond_to do |format|
      if @theme.update_attributes(theme_params)
        format.html { redirect_to themes_path, notice: I18n.t('commons.successfully_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /themes/1
  # DELETE /themes/1.json
  def destroy
    @theme = Theme.find(params[:id])
    @theme.destroy

    respond_to do |format|
      format.html { redirect_to themes_path, notice: I18n.t('commons.successfully_deleted') }
      format.js#
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def theme_params
      params.require(:theme).permit(:translations_attributes => [:id, :locale, :name])
    end

  protected

    def admin_required!
      current_user.is_admin? or access_denied!
    end
end
