class BaseMailer < ActionMailer::Base
  default from: "noreply@itpilot.de"
  layout 'mailers/default'

  def registration_email
    @user = params[:user]

    @subject = I18n.t('users.registration_mail_subject')

    if Rails.env.production?
      @to = "itpilot@netcos.de"
    else
      @to = "s.prohorov1981@gmail.com"
    end
    mail(to: @to, subject: @subject)

  end
end