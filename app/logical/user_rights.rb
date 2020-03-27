module UserRights
  extend ActiveSupport::Concern


  included do
    helper_method :current_company
  end

  def current_company
    cc = session['app.current_company'] || nil
    if cc.present?
      if current_user.is_admin?
        c = Company.jvp.where(id: cc).first
      else
        c = current_user.companies.where(id: cc).first
      end
    else
      if current_user.is_admin?
        c = Company.jvp.first
      else
        c = current_user.companies.first
      end
    end

    current_user.current_company = c
    current_user.save
    c
  end

  def companies_scope
    if current_user.is_admin? || current_company.is_jvp?
      Company.jvp
    else
      []
    end
  end

  def partner_scope
    if current_user.is_admin? || current_company.is_jvp?
      current_company.children.partner
    elsif current_company.is_partner?
      Company.partner.where(id: current_company)
    else
      Company.none
    end
  end

  def customer_scope
    #order changed
    if current_user.is_admin? && params[:company_id] && c = Company.find_by_id(params[:company_id])
      Company.customer.where(parent_id: [c.id] + c.children.partner.pluck(:id))
    elsif current_user.is_admin?
      Company.customer
    elsif current_company.is_customer?
      Company.where(id: current_company.id)
    elsif current_company.is_partner?
      current_company.children.customer
    elsif current_company.is_jvp?
      Company.customer.where(parent_id: [current_company.id] + current_company.children.partner.pluck(:id))
    else
      Company.none
    end
  end

end