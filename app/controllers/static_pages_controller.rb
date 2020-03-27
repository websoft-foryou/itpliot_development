class StaticPagesController < ApplicationController
  before_action :admin_required!

  def index
    @filters = {search: params[:search]}
    @static_pages = StaticPage.all

    if @filters[:search].present?
      @static_pages = @static_pages.where('LOWER(static_pages.title) LIKE :search', search: "%#{@filters[:search].downcase}%")
    end
    @static_pages = @static_pages.page(params[:page]).per_page(default_per_page)
  end

  def new
    @static_page = StaticPage.new
    @static_page.locale = I18n.locale.to_s
    @static_page.generate_uid!
  end

  def edit
    @static_page = StaticPage.where(uid: params[:id], locale: params[:locale]).first_or_initialize
    render :new
  end

  def update
    @static_page = StaticPage.where(locale: params[:locale], uid: params[:id]).first_or_initialize

    if @static_page.update_attributes static_pages_params
      flash[:notice] = I18n.t("static_pages.saved_successfully")
      redirect_to edit_static_page_path @static_page.uid, locale: @static_page.locale
    else
      render :edit
    end
  end

  def destroy
    @static_page = StaticPage.where(uid: params[:id], locale: params[:locale]).first

    @static_page.destroy

    redirect_to static_pages_path
  end

  protected

  def admin_required!
    current_user.is_admin? || access_denied!
  end

  private

  def static_pages_params
    params.require(:static_page).permit(:title, :description, :user_type_permission, :locale)
  end
end
