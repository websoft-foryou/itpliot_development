class ApplicationController < ActionController::Base
  include ::UserRights
   
  before_action :authenticate_user!, :set_locale

  def current_timezone
    @current_timezone ||= (cookies['current_timezone'] || 'UTC')
  end

  helper_method :current_timezone

  def browser_locale
    locale_based_on_browser
  end

  protected

  def set_locale
    I18n.locale = if user_signed_in?
                    current_user.current_locale
                  else
                    locale_based_on_browser
                  end
  end

  def locale_based_on_browser
    locale = extract_locale_from_accept_language_header

    locale_valid?(locale) ? locale : 'en'
  end

  def default_per_page
    10
  end

  def access_denied!
    redirect_to root_path, alert: 'Access denied'
  end


  def user_accept_terms_required!
    redirect_to step1_homes_path, alert: I18n.t('users.follow_step_complete_registration') unless current_user.accept_terms?
  end


  private

  def locale_valid?(locale)
    I18n.available_locales.map(&:to_s).include?(locale)
  end

  def extract_locale_from_accept_language_header
    accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
    return unless accept_language

    accept_language.scan(/^[a-z]{2}/).first
  end

  def admin_required!
    current_user.is_admin? || access_denied!
  end

end
