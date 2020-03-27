class ServiceRequestMailer < BaseMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.service_request_mailer.service_request.subject
  def service_request(service_name, description, prod_example, company_name, contact, contact_email, telephone, reason_remark)

    @service_name = service_name
    @description = description
    @prod_example = prod_example
    @company_name = company_name
    @contact = contact
    @contact_email = contact_email
    @telephone = telephone
    @reason_remark = reason_remark
  
    @subject = "[itpilot] - Request new service"
    @sent_to = User.admin.pluck(:email)
    mail(to: @sent_to, subject: @subject)
  end
end
