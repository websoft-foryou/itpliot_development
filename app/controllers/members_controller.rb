class MembersController < ApplicationController
  before_action :user_accept_terms_required!, except: [:parent_companies]
  before_action :check_customer_branch, only: [:new]
  before_action :check_invite_permitted, only: [:invite]
  before_action :authenticate_user!, except: [:parent_companies]

  def index
    @filters = {search: params[:search]}
    @users = user_scope
    set_breadcrumb

    if params[:customer_id]
      @customer = customer_scope.find(params[:customer_id])
      @users = @customer.all_users
    elsif params[:reseller_id]
      @partner = partner_scope.find(params[:reseller_id])
      @users = @partner.all_users
    elsif params[:company_id]
      @jvp = companies_scope.find(params[:company_id])
      @users = @jvp.all_users
    end

    if @filters[:search].present?
      @users = @users.where("LOWER(users.last_name) LIKE :search OR LOWER(users.email) LIKE :search", search: "%#{@filters[:search].downcase}%")
    end

    @users = @users.order("users.last_name").page(params[:page]).per_page(default_per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def new
    @user = user_scope.new
    @customer = Company.customer.find_by_id(params[:customer_id]) if params[:customer_id]
    @partner = Company.partner.find_by_id(params[:reseller_id]) if params[:reseller_id]
    company_users_options

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def edit
    session['members.back_path'] = request.referrer
    @user = user_scope.find(params[:id])
    company_users_options
  end

  def select
    @users = user_scope.where("LOWER(users.email) || ' ' || LOWER(users.first_name) || ' ' || LOWER(users.last_name) LIKE :search", {search: "%#{params[:search].downcase}%"}).limit(15)
    # if params[:scope].present?
    #   params[:scope].split(',').each do |scp|
    #     @users = @users.public_send(scp)
    #   end
    # end
    if params[:company_id].present?
      company_users = CompanyUser.where(:company_id=>params[:company_id]).pluck(:user_id)
      @users = @users.select {|u| !u.id.in? company_users}
    end
    respond_to do |format|
      format.json#
    end
  end

  def parent_companies
    companies = []

    if params[:role_type] == User::ROLE_TYPES.index(:partner).to_s
      if current_user.is_admin?
        companies = Company.jvp.all
      elsif current_company.is_jvp?
        companies << current_company
      end
    elsif params[:role_type] == User::ROLE_TYPES.index(:customer).to_s
      if current_user.is_admin?
        companies = Company.partner.all
      elsif current_company.is_jvp?
        companies = Company.partner.where(:parent_id => current_company.id)
      end
    end
    respond_to do |format|
      format.json { render json: companies }
    end

  end

  def invite
    redirect = members_path
    
    if current_user.email == params[:user][:email]
      redirect_back(fallback_location: new_member_path, alert: I18n.t('users.messages.already_assign_email'))
    else
      u = User.where(:email => params[:user][:email]).first
      if u
        #params[:user][:first_name] = u.first_name
        #params[:user][:last_name] = u.last_name
        #
        #u.company_users.each{|d| d.destroy}
        redirect_back(fallback_location: new_member_path, alert: I18n.t('users.messages.already_assign_email'))
        return
      end

      @user = User.invite! user_params, current_user do |u|
        u.skip_confirmation!
        u.skip_invitation = current_user.is_admin? && params[:addto].blank? && params[:send_email].blank?
        u.sent_email = true unless u.skip_invitation
        u.invitation_sent_at = Time.now.utc
        if u.role_type == User::ROLE_TYPES.index(:partner) || u.role_type == User::ROLE_TYPES.index(:customer)
          u.invitation_parent_company_id = params[:invitation_parent_company_id]
        elsif params[:addto].present?
          if params[:reseller_id]
            u.invitation_parent_company_id = params[:reseller_id]
          elsif params[:customer_id].present? && c = Company.customer.find_by_id(params[:customer_id])
            u.invitation_parent_company_id = c.parent_id
          end
        end
        u.locale = current_user.locale
  
        if params[:addto].present?
          if params[:customer_id].present? && c = Company.customer.find_by_id(params[:customer_id])
            redirect = customer_path(c) if current_user.is_admin?
            redirect = company_reseller_customer_path(current_company, c.parent, c) if session[:by_reseller] && c.parent && c.parent.is_partner?
          elsif params[:reseller_id].present? && r = Company.partner.find_by_id(params[:reseller_id])
            redirect = company_reseller_path(r.parent,r) if current_user.is_admin?
          end
        end
      end
      respond_to do |format|
        if @user.persisted?
          @user.update_attribute(:short_token, @user.raw_invitation_token)
          message = if current_user.is_admin? && params[:send_email].blank?
            I18n.t('users.invitation.messages.send_instructions_without_email', email: @user.email)
          else
            I18n.t('devise.invitations.send_instructions', email: @user.email)
          end
          format.html { redirect_to redirect, notice: message}
        else
          @user = user_scope.new
          format.html { render action: "new" }
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = user_scope.find(params[:id])
    company_users_options
    if params["user"]["company_users_attributes"].present?
      @user.company_users.where("id NOT IN (?)", params["user"]["company_users_attributes"].values().pluck(:id).select{|a| !a.blank?}).each{|d| d.destroy}
    elsif
      @user.company_users.each{|d| d.destroy}
    end
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html {
          redirect_to (session['members.back_path'] || members_path), notice: I18n.t('commons.successfully_updated')
        }
        format.json { head :no_content }
      else
        flash[:error] = @user.errors.full_messages.join(', ').html_safe
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = user_scope.find(params[:id])
      @user.destroy if @user.id != current_user.id

      respond_to do |format|
      format.html {
        redirect_to session['members.back_path'] and return if session['members.back_path']
        redirect_to members_path
      }
      format.json { head :no_content }
      format.js#
      end
  end


  private
    def user_params
      permit = [:first_name, :last_name]
      permit << :email if params[:action] == "invite"
      permit << :role_type

      permit << {company_users_attributes: [:id, :company_id, :company_branch_id]} if (!params[:role_type])

      params.require(:user).permit(*permit)
    end

    def check_invite_permitted
      return if current_user.is_admin? || current_company.is_jvp?
      return if params[:addto].present?

      access_denied!
    end

    def company_users_options
      @company_users = []

      if params[:customer_id].present?
        c = Company.find(params[:customer_id])
        c.company_branches.each do |b|
          @company_users << CompanyUser.where(user_id: @user.id, company_id: c.id, company_branch_id: b.id).first_or_initialize
        end
      elsif params[:reseller_id].present?
        c = Company.find(params[:reseller_id])
        @company_users << CompanyUser.where(user_id: @user.id, company_id: c.id).first_or_initialize
        # c.children.customer.each do |c1|
        #   c1.company_branches.each do |b|
        #     @company_users << CompanyUser.where(user_id: @user.id, company_id: c1.id, company_branch_id: b.id).first_or_initialize
        #   end
        # end
      else
        if current_user.is_admin?
          Company.jvp.each do |c|
            company_users_children_options(c)
          end
        elsif
          company_users_children_options(current_company)
        end
      end
    end

    def company_users_children_options c
      if c.is_jvp?
        @company_users << CompanyUser.where(user_id: @user.id, company_id: c.id).first_or_initialize

        c.children.partner.each do |c1|
          @company_users << CompanyUser.where(user_id: @user.id, company_id: c1.id).first_or_initialize
          c1.children.customer.each do |c2|
            c2.company_branches.each do |b|
              @company_users << CompanyUser.where(user_id: @user.id, company_id: c2.id, company_branch_id: b.id).first_or_initialize
            end
          end
        end
        c.children.customer.each do |c1|
          c1.company_branches.each do |b|
            @company_users << CompanyUser.where(user_id: @user.id, company_id: c1.id, company_branch_id: b.id).first_or_initialize
          end
        end
      elsif c.is_partner?
        @company_users << CompanyUser.where(user_id: @user.id, company_id: c.id).first_or_initialize
        c.children.customer.each do |c1|
          c1.company_branches.each do |b|
            @company_users << CompanyUser.where(user_id: @user.id, company_id: c1.id, company_branch_id: b.id).first_or_initialize
          end
        end
      end

    end
    def check_customer_branch
      if params[:addto] && params[:customer_id]
        c = Company.customer.find_by(id: params[:customer_id])
        unless c && c.company_branches.any?
          redirect_back(fallback_location: root_path, alert: I18n.t('users.messages.you_must_add_location'))
        end
      end
    end

    def user_scope
      if current_user.is_admin?
        User
      else
        current_company.all_users
      end

    end

    def set_breadcrumb
      session[:breadcrumb] = {key: 'users', name: t('users.users'), url: members_path}
    end


end
