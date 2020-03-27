class EvaluationService < BaseModel
  STATUSES = [:ignored, :deactivated, :active, :draft]

  belongs_to :evaluation
  belongs_to :service

  # validates :service_id, presence: true, uniqueness: {scope: :evaluation_id}


  scope :active, -> { where(status: STATUSES.index(:active)) }
  scope :ignored, -> { where(status: STATUSES.index(:ignored)) }
  scope :deactivated, -> { where(status: STATUSES.index(:deactivated)) }
  scope :draft, -> { where(status: STATUSES.index(:draft)) }


  STATUSES.each.with_index do |status_type, i|
    define_method "is_#{status_type}?" do
      self.status == i
    end
  end

  def status_name
    STATUSES[self.status]
  end
end
