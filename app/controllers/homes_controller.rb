class HomesController < ApplicationController
  #before_action :user_customer_or_partner_required!, except: [:show, :step1]
  before_action :user_has_company!, only: :step2_create
  before_action :user_has_no_company!, only: :step3
  before_action :partner_required, only: :partner_step3

  def show
    session['homes.step'] = nil

    redirect_to action: :step1 and return unless current_user.accept_terms
    redirect_to action: :step2 and return unless current_company
    if current_company.is_customer? || current_company.is_partner?
      t = Time.now - (current_user.current_sign_in_at || Time.now)
      if t < 5
        redirect_to action: :step2 and return unless current_user.companies.first
        redirect_to action: :step3 and return if (current_company.is_customer? && !current_company.company_branches.any?)
      end
    end
  end

  def step1
    session['homes.step'] = 1
  end

  def step2
    session['homes.step'] = 2

    if params[:load_sample]
      @company = Company.sample_customer.clone_company
      @company.is_sample = false
    else
      @company = current_user.companies.first_or_initialize do |c|
        if current_user.invitation_parent_company_id
          c.parent_id = current_user.invitation_parent_company_id
        else
          c.parent = Company.default_parent.children.partner.first
        end
          # c.company_type = current_user.company_default_type
        c.company_type = current_user.role_type || current_user.company_default_type  # Since User.role_type is equal to Company.company_type at value
      end
    end
    @company.build_location unless @company.location
  end

  def step2_create
    @company = current_user.companies.build(customer_params)
    # @company.company_type = current_user.company_default_type
    @company.company_type = current_user.role_type || current_user.company_default_type

    if current_user.invitation_parent_company_id
      @company.parent_id = current_user.invitation_parent_company_id
    else
      @company.parent = Company.default_parent.children.partner.first
    end

    if @company.is_partner?
      @company.plan_id = Plan::for_partner.first.id
      #@company.premium_from = Time.now
      #@company.premium_until = Time.now.end_of_month
    elsif @company.is_direct_customer?
      @company.plan_id = Plan::for_customer.first.id
    end

    if @company.save
      CompanyRegisterMailer.send_request(@company.id).deliver

      @company.company_users.create(user_id: current_user.id)
      redirect = @company.is_partner? ? partner_step3_homes_path : step3_homes_path
      redirect_to redirect, notice: I18n.t('commons.successfully_created')
    else
      render action: "step2"
    end
  end

  def step3
    @should_show_finnish_proccess = session["homes.step"].present? && session['homes.step'] == 2
    session['homes.step'] = 3
    @company = current_company
    @company_branch = @company.company_branches.first_or_initialize
  end

  def partner_step3
    @customer = customer_scope.build
    @customer.build_location
  end

  def create_customer
    invoice = {Invoice: {
        InvoiceID: 50002,
        Invoice_PeriodStartDate: '2019-07-17',
        Invoice_PeriodEndDate: '2019-10-17',
        Invoice_Lines: {
          Line: {
            LineNo: 1,
            ProductID: 'itp_bpa_pa1_q',
            Quantity: 1
          }
        },
        Customer: {
          CustomerID: 60002,
          CustomerName: 'Alex Ivanov',
          TaxID: 122,
          Contact_Title: "Mr",
          Contact_Forename: 'Alex',
          Contact_Surname: 'Ivanov',
          Billing_Company: 'billing Company',
          Billing_Street: 'billing street',
          Billing_City: 'city',
          Billing_PostalCode: '12345'
        }
      }
    }
    SapBusinessOne.new.create_customer(invoice)
    # abort("here I am")
  end

  private
    def customer_params
      permit = [:name, :name2, :vat_number, :business_id, :phone, :mobile, :contact_person, :email, :invoice_email, :url, :remarks, :avatar, location_attributes: [:id, :latitude, :longitude, :address, :address2, :city, :country, :zip]]
      params.require(:company).permit(*permit)
    end

    def user_has_company!
      redirect_to root_path if current_user.companies.first
    end

    def user_has_no_company!
      redirect_to root_path unless current_user.companies.first
    end

    def user_customer_or_partner_required!
      current_company.is_customer? || current_company.is_partner? || access_denied!
    end

    def partner_required
      current_company.is_partner? || access_denied!
    end

end
