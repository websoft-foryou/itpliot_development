class ServiceRequest < BaseModel
    validates :service_name, :description, :prod_example, :company_name, :contact, :email, :telephone, :reason, presence: true
end
