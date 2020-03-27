class ChangeSubscriptionMailer < BaseMailer
  def send_request(company_id, plan_id, user_id)
    @company = Company.find company_id
    @plan = Plan.find plan_id

    @user = User.find user_id

    @subject = "[it.pilot] - #{@company.name} requested a subscription change"

    @sent_to = User.admin.pluck(:email)
    mail(to: @sent_to, subject: @subject)
  end
end
