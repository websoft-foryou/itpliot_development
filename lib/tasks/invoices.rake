namespace :invoices do
  desc "Issue invoices for premium partner/customer"

  task create_invoice: :environment do
    puts ">>>>>>>>>>> 'create_invoice' cron job started at #{Time.now} >>>>>>>>>>>"

    Company.where("plan_id IS NOT NULL").each do |company|
      unless company.invoices.where("premium_until > ? OR status != 2", Time.now).first
        premium_from = Time.now
        premium_until = Time.now.end_of_day #Date.today.end_of_quarter

        PlanRequest.invoicing(company.id, company.plan_id, premium_from, premium_until)
        company.update_attributes(premium_from: premium_from, premium_until: premium_until)
      end
    end
  end

  task check_invoice: :environment do
    puts ">>>>>>>>>>> 'check_invoice' cron job started at #{Time.now} >>>>>>>>>>>"

    # Fetch unpaid invoices and downgrade specific company to FREMIUM if overdue
    Invoice.where("status != 2 AND status != 3").each do |invoice|
      # TODO: Call API
      # should call invoice check status API and update status on itpilot
      # 4. Set the PAID status of an INVOICE back in itPilot:
      #
      # - a route will be called by an external service (BPA) back in itPilot with an invoice ID and the status PAID, in order to mark it as PAID.
      # A response from itPilot must be received(logic TRUE/FALSE). In case the response received is not TRUE(the invoice status has not been marked as PAID),
      # the BPA must retry or alert the administrators that something went wrong!

      result = SapBusinessOne.new.get_invoice(invoice.id)
      # if API response is not paid status
      if result.code == 200 and result.parsed_response["RunTaskRestResponse"]["TaskStatusCode"] == 2
        if result.parsed_response["RunTaskRestResponse"]["OutputParameters"]["Result"] == "Invoice has been paid"
          invoice.update_attribute(:status, 2)
          SubscriptionMailer.invoicing(invoice.id).deliver
        else
          if invoice.due_date < Time.now
            invoice.update_attribute(:status, 3)
            SubscriptionMailer.invoicing(invoice.id).deliver
            PlanRequest.downgrade(invoice.company_id)
          end
        end
      end
    end
  end

end
