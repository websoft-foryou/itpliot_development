class ExportDataController < ApplicationController
  before_action :admin_required!

  FILE_NAME = "tempfile"

  def index
    @logs = UserActivity.where(action_type: UserActivity::ACTION_TYPES.index(:export_data))
    render :index
  end

  def download
    @data = []

    if !params[:password] or params[:password] != 'itpilot'
      redirect_to export_data_path, alert: I18n.t('commons.password_invalid')
      return
    end

    if params[:company_information]
      item = []
      item << I18n.t('companies.company_information')
      item << [ I18n.t('commons.id'), I18n.t('companies.type'), I18n.t('commons.belongs_to'), I18n.t('customers.membership'), I18n.t('upgrade.premium_period'), I18n.t('upgrade.continue_every_month'), I18n.t('upgrade.issue_invoice'), I18n.t('companies.form.name'), I18n.t('companies.form.name2'), I18n.t('companies.form.vat_number'), I18n.t('companies.form.industry'), I18n.t('companies.form.contact_person'), I18n.t('companies.form.phone'), I18n.t('companies.form.mobile'), I18n.t('companies.form.email'), I18n.t('companies.form.contact_person2'), I18n.t('companies.form.phone2'), I18n.t('companies.form.mobile2'), I18n.t('companies.form.email2'), I18n.t('companies.form.url'), I18n.t('companies.form.address1'), I18n.t('companies.form.address2'), I18n.t('companies.form.zip'), I18n.t('companies.form.city'), I18n.t('companies.form.country'), I18n.t('companies.form.remarks'), ]
      rows = []
      Company.all.each do |c|
        c.build_location unless c.location
        row = [ c.id, c.company_type_name, c.parent_id, c.membership_name, c.membership_period, c.name, c.name2, c.vat_number, c.business_name, c.contact_person, c.phone, c.mobile, c.email, c.contact_person2, c.phone2, c.mobile2, c.email2, c.url, c.location.address, c.location.address2, c.location.zip, c.location.city, c.location.country, c.remarks ]
        rows << row
      end
      item << rows
      @data << item
    end

    if params[:service_sets]
      item = []
      item << I18n.t('services.service_sets')
      item << [ I18n.t('commons.id'), I18n.t('services.code'), I18n.t('commons.name') ]
      rows = []
      Service.all.each do |s|
        row = [ s.id, s.code, s.name ]
        rows << row
      end
      item << rows
      @data << item
    end

    if params[:invoices]
      item = []
      item << I18n.t('invoice.title')
      item << [ I18n.t('commons.id'), I18n.t('companies.company'), I18n.t('upgrade.plan'), I18n.t('invoice.amount'), I18n.t('invoice.invoiced_date'), I18n.t('invoice.due_date'), I18n.t('invoice.internal_invoice_no'), I18n.t('invoice.status') ]
      rows = []
      Invoice.all.each do |i|
        row = [ i.id, i.company.name, i.plan ? i.plan.name : '', i.plan ? i.plan.price : '', i.issued_date, i.due_date, i.internal_no, i.status_name ]
        rows << row
      end
      item << rows
      @data << item
    end

    if params[:users]
      item = []
      item << I18n.t('users.users')
      item << [ I18n.t('commons.id'), I18n.t('users.first_name'), I18n.t('users.last_name'), I18n.t('users.email'), I18n.t('users.role_type'), I18n.t('commons.status') ]
      rows = []
      User.all.each do |u|
        row = [ u.id, u.first_name, u.last_name, u.email, u.role_name, u.status_name ]
        rows << row
      end
      item << rows
      @data << item
    end

    if params[:company_members]
      item = []
      item << I18n.t('company_users.title')
      item << [ I18n.t('companies.company')+I18n.t('commons.id'), I18n.t('users.user')+I18n.t('commons.id') ]
      rows = []
      CompanyUser.all.order("company_id").each do |cu|
        row = [ cu.company_id, cu.user_id ]
        rows << row
      end
      item << rows
      @data << item
    end

    # Log download history
    description_str = []
    if params[:company_information] && params[:service_sets] && params[:invoices] && params[:users] && params[:company_members]
      description_str.push(I18n.t('export_data.full_customer_data'))
    else
      description_str.push(I18n.t('companies.company_information')) if params[:company_information]
      description_str.push(I18n.t('services.service_sets')) if params[:service_sets]
      description_str.push(I18n.t('invoice.title')) if params[:invoices]
      description_str.push(I18n.t('users.users')) if params[:users]
      description_str.push(I18n.t('company_users.title')) if params[:company_members]
    end
    UserActivity.create(user_id: current_user.id, action_type: UserActivity::ACTION_TYPES.index(:export_data), description: description_str.join(", "))

    render "download.xlsx.axlsx"
  end

  def download_zip
    @companies = Company.all

    @files = []
    package = Axlsx::Package.new
    wb = package.workbook
    wb.add_worksheet(name: "filename1") do |sheet|
      sheet.add_row ["First Column", "Second", "Third"]
    end
    @files << package

    @files.each do |file|
      file.serialize "#{file.workbook.worksheets.first.name}.xls"
    end


    begin
      temp = Tempfile.new FILE_NAME
      Zip::File.open(temp.path, Zip::File::CREATE) do |zipfile|
        @files.each do |file|
          zipfile.add "#{file}.xls", "#{Rails.root}/#{file}.xls"
        end
      end
      @files.each do |file|
        File.delete "#{file}.xls"
      end
    rescue Errno::ENOENT, IOError => e
      Rails.logger.error e.message
      temp.close
    end

    send_file temp.path, type: "application/zip", x_sendfile: true, disposition: "attachment", filename: "Budgets.zip"
  end

end
