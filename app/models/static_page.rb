class StaticPage < BaseModel

  validates :title, presence: true, length: { maximum: 255 }
  validates :uid, uniqueness: { scope: :locale }
  validates :locale, presence: true

  scope :for_locale, ->(locale) { where(locale: locale) }

  def generate_uid!(limit = 6)
    self.uid = loop do
      random_token = SecureRandom.urlsafe_base64(limit, false).downcase
      break random_token unless self.class.where(uid: random_token).exists?
    end
  end

  def accessible_by? user
    return true if !user and user_type_permission.blank?
    return false if !user
    return true if user.is_admin? || user_type_permission.blank?
  end

end
