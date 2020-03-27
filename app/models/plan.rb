class Plan < BaseModel
  PARTNER_MAX_EMPLOYEES = 200
  CUSTOMER_MAX_EMPLOYEES = 1000

  PERIOD_DAYS = 1

  def self.for_partner
    Plan.where(company_type: Company::COMPANY_TYPES.index(:partner)).order(:employees_from)
  end

  def self.for_customer
    Plan.where(company_type: Company::COMPANY_TYPES.index(:customer)).order(:employees_from)
  end

  def name
    employees_from > CUSTOMER_MAX_EMPLOYEES ? "> #{employees_from-1}" : "#{employees_from}-#{employees_to} #{I18n.t('employees.employees')}"
  end
end
