class LicensesController < ApplicationController
  def index
    @licenses = License.all
    @licenses = License.includes(:translations).with_locales(I18n.locale).order('license_translations.description')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @licenses }
    end
  end

  def new
    @license = License.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @license }
    end
  end

  def show

  end

  # POST /licenses
  # POST /licenses.json
  def create
    @license = License.new(license_params)
    respond_to do |format|
      if @license.save
        format.html { redirect_to licenses_path, notice: I18n.t('commons.successfully_created') }
        format.json { render json: @license, status: :created, location: @license }
      else
        format.html { render action: "new" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @license = License.find(params[:id])
  end

  # PATCH/PUT /licenses/1
  # PATCH/PUT /licenses/1.json
  def update
    @license = License.find(params[:id])

    respond_to do |format|
      if @license.update_attributes(license_params)
        format.html { redirect_to licenses_path, notice: I18n.t('commons.successfully_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @license.errors, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /licenses/1
  # DELETE /licenses/1.json
  def destroy
    @license = License.find(params[:id])
    @license.destroy

    respond_to do |format|
      format.html { redirect_to licenses_path, notice: I18n.t('commons.successfully_deleted') }
      format.js#
      format.json { head :no_content }
    end
  end

  private
    def license_params
      params.require(:license).permit(:name, :price, :days, :incl_freemium, :incl_premium, :incl_partner, :translations_attributes => [:id, :locale, :description])
    end


end
