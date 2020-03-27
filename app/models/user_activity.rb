class UserActivity < BaseModel
  ACTION_TYPES = [:export_data]

  belongs_to :user
end
