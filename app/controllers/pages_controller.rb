class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:dynamic]
  skip_before_action :authenticate_user!

  def show
    render "pages/#{params[:id]}"
  end

  def dynamic
    locale = params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym) && params[:locale] || I18n.locale
    @static_page = StaticPage.where(uid: params[:id], locale: locale).first
    render status: 404, nothing: true and return if @static_page.nil? || !@static_page.accessible_by?(current_user)
  end
end
