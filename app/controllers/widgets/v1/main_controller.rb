class Widgets::V1::MainController < ::ApplicationController
  layout 'widgets/v1/application'
  skip_before_action :authenticate_user!

  protected

  def set_locale
    I18n.locale = if params[:lang].present? && I18n.available_locales.include?(params[:lang].to_sym)
                    params[:lang]
                  else
                    locale_based_on_browser
                  end
  end
end
