class SubscriptionMailer < BaseMailer
  ADMINISTRATORS = User.admin.pluck(:email)

  def upgrade_plan(company_id, plan_id, requester_id)
    @company = Company.find company_id
    @plan = Plan.find plan_id
    @requester = User.find requester_id

    @subject = "[itpilot] - #{@company.name} requested subscription upgrade"

    @sent_to = ADMINISTRATORS
    mail(to: @sent_to, subject: @subject)
  end

  def change_plan(company_id, plan_id, requester_id)
    @company = Company.find company_id
    @plan = Plan.find plan_id

    @requester = User.find requester_id

    @subject = "[it.pilot] - #{@company.name} requested a subscription change"

    @sent_to = ADMINISTRATORS
    mail(to: @sent_to, subject: @subject)
  end

  def downgrade_plan(company_id, plan_id)
    @company = Company.find company_id
    @plan = Plan.find plan_id

    @subject = "[it.pilot] - #{@company.name} was downgraded"

    @sent_to = ADMINISTRATORS
    mail(to: @sent_to, subject: @subject)
  end


  def invoicing(invoice_id)
    @invoice = Invoice.find invoice_id
    @company = @invoice.company
    @plan = @invoice.plan

    @subject = "[itpilot] - #{@company.name}'s invoice(#{invoice_id}) was #{@invoice.status_name}"

    @sent_to = ADMINISTRATORS
    mail(to: @sent_to, subject: @subject)
  end

  def invoicing_error(company_id, invoice_id)
    @invoice = Invoice.find invoice_id
    @company = Company.find company_id
    @plan = @invoice.plan

    @subject = "[itpilot] - #{@company.name}'s invoicing(invoice id: #{invoice_id}) was failed"

    @sent_to = ADMINISTRATORS
    mail(to: @sent_to, subject: @subject)
  end
end
