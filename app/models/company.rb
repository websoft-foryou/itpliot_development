class Company < BaseModel
  COMPANY_TYPES = [:jvp, :partner, :customer]

  before_save :url_add_protocol

  has_many :company_users, dependent: :destroy
  has_many :users, through: :company_users
  has_one :location, dependent: :destroy
  belongs_to :business

  has_many :company_branches, -> { where(deleted: !true) }, dependent: :destroy
  # has_many :services, source: :owner, dependent: :nullify, foreign_key: :owner_id
  has_many :evaluations, dependent: :destroy
  # has_many :customer_evaluations, dependent: :destroy, foreign_key: :customer_id
  has_many :evaluation_results, dependent: :destroy, through: :evaluations
  has_many :customer_evaluations, dependent: :destroy, foreign_key: "customer_id", class_name: "Evaluation"

  has_many :invoices, dependent: :destroy
  belongs_to :plan
  belongs_to :revised_plan, class_name: "Plan"

  belongs_to :parent, class_name: "Company", foreign_key: :parent_id
  has_many :children, class_name: "Company", foreign_key: :parent_id

  has_many :employees, class_name: "Employee", foreign_key: :customer_id


  has_attached_file :avatar, styles:
    {
        thumb: { geometry: "60x60#", format: :jpg, convert_options: "-colorspace RGB" },
        list: { geometry: "180x180#", format: :jpg, convert_options: "-colorspace RGB" },
        original: { geometry: "1280x720>", format: :jpg }
    }, processors: [:thumbnail],
    path: ":rails_root/public/system/companies/:style/:id_partition_:style.:extension",
    url: "/system/companies/:style/:id_partition_:style.:extension",
    default_url: "/default/companies/avatar/:style_default.png"

    do_not_validate_attachment_file_type :avatar


  accepts_nested_attributes_for :location, :allow_destroy => true, :reject_if => :reject_location

  validates :name,:contact_person,:business_id, presence: true
  validates :phone,:mobile, format: /\A[+]?[0-9\-.\s]{7,17}\z/, presence: true
  validates :url, :format => /\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]+?(\/.*)?\z/ix, allow_blank: true
  validates :email, format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, presence: true
  validates :invoice_email, format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, presence: true
  validates :vat_number, presence: true, uniqueness: true
  validates :phone2,:mobile2, format: /\A[+]?[0-9\-.\s]{7,17}\z/, allow_blank: true
  validates :email2, format: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/, allow_blank: true
  validates_presence_of :premium_until, if: -> { premium_from.present? }

  auto_strip_attributes :vat_number, delete_whitespaces: true

  def self.default_parent
    Company.where(default_parent: true).order(:id).first
  end

  def self.sample_customer
    Company.where(is_sample: true).first
  end

  def full_name
    "#{name} #{name2}"
  end

  def business_name
    (self.business && self.business.name.present?) ? self.business.name : I18n.t('commons.not_specified')
  end

  def descendents
    d = []
    d = self.children.map(&:id)
    self.children.each do |cc|
      d = d + (cc.children.map(&:id))
    end
    d.compact
  end

  def users_tree
    users = User.joins(:company_users)
    if self.descendents.any?
      users = users.where("company_users.company_id IN (?)", self.descendents << self.id )
    else
      users = users.where("company_users.company_id = :company",{company: self.id})
    end
  end


  def premium?
    valid_period = premium_from.present? && premium_until.present? && (premium_from..premium_until).include?(Time.now)

    return plan && valid_period if is_direct_customer? || (is_partner? && !is_dsp?)

    return parent.premium? if is_customer? && parent

    return false
  end



  COMPANY_TYPES.each.with_index do |type, index|
    scope type, ->{ where(company_type: index) }

    define_method "is_#{type}?" do
      self.company_type == index
    end
  end

  def company_type_name
    COMPANY_TYPES[self.company_type]
  end

  def generic_address
    self.location ? self.location.full_address : nil
  end

  def company_type_name=(value)
    self.company_type = COMPANY_TYPES.index(value.to_sym)
  end

  def is_blocked?
    self.is_blocked
  end

  def has_current_evaluation?
    self.is_customer? && self.customer_evaluations.where(status: Evaluation::STATUSES.index('draft'), distinguish_type: !Evaluation::TYPES.index(:sandbox)).any?
  end

  def has_sandbox_evaluation?
    self.is_customer? && self.customer_evaluations.sandbox.any?
  end

  def reject_location(attributes)
      if attributes[:address].blank?
        if attributes[:id].present?
          attributes.merge!({:_destroy => 1}) && false
        else
          true
        end
      end
  end
  def url_add_protocol
    return unless self.url.present?
    unless self.url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//]
      self.url = "http://#{self.url}"
    end
  end

  def clone_company
    cloned_obj = deep_clone(include: [
        :location
    ])
    cloned_obj
  end

  def is_direct_customer?
    self.is_customer? && (self.parent && self.parent.is_jvp?)
  end

  def premium_from_date
    return premium_from if is_direct_customer? || is_partner?
    return parent.premium_from if is_customer?
  end

  def premium_until_date
    return premium_until if is_direct_customer? || is_partner?
    return parent.premium_until if is_customer?
  end

  def membership_name
    "#{if self.premium? then 'Premium' else 'Freemium' end}"
  end

  def membership_period
    if self.premium?
      "#{I18n.l(self.premium_from_date, format: :human_short)} - #{I18n.l(self.premium_until_date, format: :human_short)}"
    else
      ''
    end
  end

  def all_users
    if self.is_jvp?
      partners = self.children.partner
      customers = Company.where('parent_id IN (?)', partners.pluck(:id))
      User.left_outer_joins(:company_users).where('company_users.company_id IN (?) OR users.invitation_parent_company_id IN (?)',[self.id] + self.children.pluck(:id) + customers.pluck(:id), [self.id] + partners.pluck(:id))
    elsif self.is_partner?
      User.left_outer_joins(:company_users).where('company_users.company_id IN (?) OR users.invitation_parent_company_id=?',[self.id] + self.children.pluck(:id), self.id)
    else
      self.users
    end
  end

  def all_company_users
    if self.is_jvp?
      partners = self.children.partner
      customers = Company.where('parent_id IN (?)', partners.pluck(:id))
      CompanyUser.where('company_id IN (?)', [self.id] + partners.pluck(:id) + customers.pluck(:id))
    elsif self.is_partner?
      CompanyUser.where('company_id IN (?)', [self.id] + self.children.pluck(:id))
    else
      CompanyUser.where(company_id: self.id)
    end
  end
end
