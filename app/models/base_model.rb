class BaseModel < ActiveRecord::Base
  self.abstract_class = true
  self.belongs_to_required_by_default = false
end
