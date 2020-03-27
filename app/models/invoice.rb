class Invoice < BaseModel
  STATUSES = [:created, :issued, :paid, :overdue]

  belongs_to :plan
  belongs_to :company

  def status_name
    self.status ? STATUSES[self.status] : ''
  end

  STATUSES.each.with_index do |type, index|
    scope type, ->{ where(status: index) }

    define_method "is_#{type}?" do
      self.status == index
    end
  end

end
