class Auth::InvitationsController < ::Devise::InvitationsController
  before_action :set_locale

  def edit
    set_minimum_password_length if respond_to? :set_minimum_password_length
    resource.invitation_token = params[:invitation_token]
    user = User.find_by_invitation_token(params[:invitation_token], true)
    if user
      I18n.locale = user.locale
      #user.update_attribute(:locale, browser_locale)
    end
  end

  def after_accept_path_for user
    step1_homes_path
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

  private

  def resource_params
    params.require(:user).permit(:password, :password_confirmation, :invitation_token)
  end

  def extract_locale_from_accept_language_header
    accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
    return unless accept_language

    accept_language.scan(/^[a-z]{2}/).first
  end

  def locale_valid?(locale)
    I18n.available_locales.map(&:to_s).include?(locale)
  end
end
