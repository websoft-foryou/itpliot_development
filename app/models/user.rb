class User < BaseModel
  ROLE_TYPES = [:admin, :partner, :customer]

  before_save :set_default_values

  devise :database_authenticatable, :recoverable, :rememberable, :confirmable, :invitable ,:registerable, :trackable, :validatable

  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  belongs_to :current_company, foreign_key: :current_company_id, class_name: "Company"

  accepts_nested_attributes_for :company_users, reject_if: proc {|a| a['company_id'].blank? }

  has_attached_file :avatar, styles:
    {
      thumb: { geometry: "60x60#", format: :jpg, convert_options: "-colorspace RGB" },
      list: { geometry: "180x180#", format: :jpg, convert_options: "-colorspace RGB" },
      original: { geometry: "1280x720>", format: :jpg }
    },
    processors: [:thumbnail],
    path: ":rails_root/public/system/users/:style/:id_partition_:style.:extension",
    url: "/system/users/:style/:id_partition_:style.:extension",
    default_url: "/default/users/avatar/:style_default.png"
  do_not_validate_attachment_file_type :avatar

  validates :first_name, :last_name, presence: true
  validates :email, format: /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i, :presence => true, uniqueness: true
  validate :password_complexity
  validates :accept_terms, inclusion: { in: [true], message: I18n.t('users.form.terms_message') }, on: :update, :if => :current_sign_in_at?

  def name
    "#{last_name} #{first_name}"
  end

  scope :without_company, ->{
      joins("left outer join company_users on company_users.user_id = users.id").where("company_users.user_id is null")
    }

  ROLE_TYPES.each.with_index do |type, index|
    scope type, ->{ where(role_type: index) }

    define_method "is_#{type}?" do
      self.role_type == index
    end
  end

  def role_name
    if role_type.present? && role_type < ROLE_TYPES.length
      I18n.t("users.role_types.#{ROLE_TYPES[role_type]}")
    else
      ''
    end
  end

  def status_name
    if invited_to_sign_up?
      I18n.t('users.invitation_sent')
    else
      I18n.t('users.email_confirmed')
    end
  end

  def company_default_type
    Company::COMPANY_TYPES.index(:customer)
  end

  def is_banned?
    false if self.is_admin?
    self.companies.each do |c|
      return true if c.is_blocked?
      return true if c.parent && c.parent.is_blocked?
      return true if c.parent && c.parent.parent && c.parent.is_blocked?
    end
    false
  end

  def active_for_authentication?
    super && !self.is_banned?
  end


  def update_without_password(params, *options)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end

  def current_locale
    return self.locale if I18n.available_locales.map{|a| a.to_s}.include? self.locale
    I18n.default_locale
  end

  private

    def set_default_values

    end

    def password_complexity
      if password.present?
        unless password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
          errors.add :password, I18n.t('users.password_must_include_upper_digits')
        end
        if password.length < 8
          errors.add :password, I18n.t('users.password_must_have_8_chars')
        end
      end
    end
end
