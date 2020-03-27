class PlanRequest
    PRODUCT_THRESHOLD = 8 * 60 # It should be changed 30 days in real system: Now it is 360 minutes
  def self.upgrade(company_id, plan_id, requester_id, requested_by_admin = false)
    company = Company.find company_id

    # if there is an unpaid invoice for this company will not handle upgrade plan request
    if company.invoices.where('status != 2').first == true
      return "Already issued invoice."
    end

    first_subscription = false
    if company.plan_id == nil
      # it means company will be upgraded from FREMIUM to PREMIUM so invoice should be immediately created
      first_subscription = true
      company.revised_plan_id = plan_id
      SubscriptionMailer.upgrade_plan(company_id, plan_id, requester_id).deliver unless requested_by_admin
    else
      SubscriptionMailer.change_plan(company_id, plan_id, requester_id).deliver unless requested_by_admin
    end

    today = Time.now
    # TODO: It should be rollbacked into end_of_quarter
    end_of_quarter = today.end_of_day #today.end_of_quarter

    company.plan_id = plan_id
    company.premium_from = today
    if ((end_of_quarter - today) / 1.minutes).to_i > PRODUCT_THRESHOLD # end_of_quarter.to_date - today.to_date > PRODUCT_THRESHOLD
      # Case 1: company A registered in January => an invoice with the left days from the quarter is issued and the company becomes Premium;
      # The cron job that runs daily will downgrade the company after 30 days if the invoice was not marked as PAID meanwhile.
      company.premium_until = end_of_quarter
      product_type = 'daily'
    else
      # Case 2: company B registers on 20’th of March(30 or less days until the new quarter) => an invoice with 2 lines is issued (for the remaining days from March and for the entire new quarter);
      # The cron job that runs daily will downgrade the company after 30 days if the invoice was not marked as PAID meanwhile.
      # TODO: It should be rollbacked into real end_of_quarter after test
      company.premium_until = (end_of_quarter + 1.days).end_of_day #(end_of_quarter + 1).end_of_quarter # next quarter end date
      product_type = 'quarter'
    end

    invoicing_result = true
    if first_subscription
      invoicing_result = invoicing(company_id, plan_id, company.premium_from, company.premium_until, product_type)
    end

    if invoicing_result == false
      return 'invoicing failure'
    end
    puts ">>>>>>>>> Company saving"
    puts company.inspect

    saving_company_result = company.save!(:validate => false)
    if saving_company_result == true
      return 'saving company ok'
    else
      return 'saving company failure'
    end
  end

  def self.downgrade(company_id)
    company = Company.find company_id
    plan_id = company.plan_id
    invoice = Invoice.where("company_id=#{company_id} AND plan_id=#{plan_id} AND premium_from=? AND premium_until=?", company.premium_from, company.premium_until).first
    invoice.destroy! if invoice
    company.update_attributes(plan_id: nil, premium_from: nil, premium_until: nil)
    # TODO: Call API
    # 3. Set the status of a customer to FREEMIUM (in order to reflect this information also in SAP BO)
    #
    # - a new URL will be called with the customer ID and the new STATUS.
    #
    # - The response will be a logic one: TRUE(changed) -> OK or FALSE (the something went wrong and an automatic alert - email will be sent to the ADMINISTRATORS)
    #

    # Send email to ADMINS
    SubscriptionMailer.downgrade_plan(company_id, plan_id)
  end

  def self.invoicing(company_id, plan_id, premium_from, premium_until, product_type='quarter')
    company = Company.find_by_id(company_id)
    plan = Plan.find_by_id(plan_id)
    invoice = # Invoice.create(company_id: company_id, plan_id: plan_id, issued_date: Time.now, due_date: Time.now + 30, premium_from: premium_from, premium_until: premium_until, status: Invoice::STATUSES.index(:created))
    invoice = Invoice.create(company_id: company_id, plan_id: plan_id, issued_date: Time.now, due_date: Time.now + 120.minutes, premium_from: premium_from, premium_until: premium_until, status: Invoice::STATUSES.index(:created))
    @invoice_id = invoice.id
    # TODO: Call API
    # should call create company detail API here and update invoice status into "issued" regarding to response
    # It is relevant to the following
    # 1. Creating a new customer in SAP BO the moment he becomes PREMIUM;
    #
    # - an external url will be called with the details of the company AND the invoice ID, AMOUNT and DATE for the customer (the status of the invoice will be CREATED);
    #
    # - the format used will be JSON;
    #
    # - The response will be a logic one: TRUE(created) -> in itPilot the status of the invoice becomes ISSUED! or FALSE (the status of the invoice remains CREATED and an automatic alert - email will be sent to the ADMINISTRATORS)
    #
    # 2. Issue an invoice for the customers;
    #
    # - the cron job that runs at the beginning of every quarter will send the new invoice details will call a new URL with the ID of the customer and the details of the NEW INVOICE; Current invoice status is: ISSUED.
    #
    # - The response will be a logic one: TRUE(created) -> in itPilot the status of the invoice becomes ISSUED! or FALSE (the status of the invoice remains CREATED and an automatic alert - email will be sent to the ADMINISTRATORS)

    contactPersonNameArray = company.contact_person.split(' ')

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Invoice {
        xml.InvoiceID invoice.id
        xml.InvoiceRemarks 'Ihre itpilot-Abrechnung ' + invoice.premium_from.strftime('%F') + ' - ' + invoice.premium_until.strftime('%F')
        xml.Invoice_PeriodStartDate invoice.premium_from.strftime('%F')
        xml.Invoice_PeriodEndDate invoice.premium_until.strftime('%F')
        xml.Invoice_Lines {
          if (product_type == 'quarter')
            xml.Line {
              xml.LineNo 1
              xml.ProductID plan.quarter_product_id
              xml.Quantity 1
            }
            if premium_until > premium_from.end_of_day #premium_from.end_of_quarter
                xml.Line {
                    xml.LineNo 2
                    xml.ProductID plan.daily_product_id
                    xml.Quantity ((premium_from.end_of_day - premium_from) / 1.hours).to_i #(premium_from.end_of_quarter.to_date - premium_from.to_date).to_i
                }
            end
          else
            xml.Line {
              xml.LineNo 1
              xml.ProductID plan.daily_product_id
              xml.Quantity ((premium_until - premium_from) / 1.hours).to_i #(premium_until.to_date - premium_from.to_date).to_i
            }
          end
        }
        xml.Customer {
          xml.CustomerID company.customer_code
          xml.CustomerName company.name
          xml.TaxID company.vat_number
          xml.Contact_Title "Mr"
          xml.Contact_Forename contactPersonNameArray[0]
          xml.Contact_Surname contactPersonNameArray[1]
          xml.Billing_Company company.name
          if company.location.present?
            xml.Billing_Street company.location.address
            xml.Billing_City company.location.city
            xml.Billing_PostalCode company.location.zip
          end
        }
      }
    end

    is_default_jvps_child = false;

    if (company.parent.present? and company.parent.id == Company.default_parent.id) or (company.parent.parent.present? and company.parent.parent.id == Company.default_parent.id)
      is_default_jvps_child = true;
    end

    api_response_is_okay = false;

    if is_default_jvps_child == true
      result = SapBusinessOne.new.create_customer(builder.to_xml)
      if result.is_a?(String) == true
        puts ">>>>>> invoicing error"
        puts result[8, result.length - 8]
        requested_by_admin = false
        SubscriptionMailer.invoicing_error(company_id, @invoice_id).deliver unless requested_by_admin
        return false
      end
      puts ">>>>>> API result"
      puts result.inspect
      puts result.code
      puts result.parsed_response
      # if API response is OK
      if result.code == 200 and result.parsed_response["RunTaskRestResponse"]["TaskStatusCode"] == "2"
        api_response_is_okay = true;
      end
    end

    if is_default_jvps_child == false or api_response_is_okay == true
      invoice.update_attribute(:status, Invoice::STATUSES.index(:issued))
      SubscriptionMailer.invoicing(invoice.id).deliver
    end
    return true
  end
end