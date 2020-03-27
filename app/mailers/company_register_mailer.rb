class CompanyRegisterMailer < BaseMailer
  def send_request(company_id)
    @company = Company.find company_id
    @subject = "[it.pilot] - New company \"#{@company.name}\" was registered"

    @sent_to = User.admin.pluck(:email)
    mail(to: @sent_to, subject: @subject)
  end
end
