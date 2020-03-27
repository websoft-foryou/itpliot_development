class ServiceDependance < BaseModel
  belongs_to :service
  belongs_to :depending, :class_name => "Service"
end
