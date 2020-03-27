class EvaluationResultFile < BaseModel
  belongs_to :evaluation_result

  has_attached_file :asset, styles:{
      thumb: { geometry: "150x150#", format: :jpg, convert_options: "-colorspace RGB" },
      original: { geometry: "1280x720>", format: :jpg }
    },
    processors: [:thumbnail],
    path: ":rails_root/public/system/evaluation_results/:style/:id_partition_:style.:extension",
    url: "/system/evaluation_results/:style/:id_partition_:style.:extension",
    default_url: "/default/evaluation_results/avatar/:style_default.png"

  validates_attachment_content_type :asset, :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp']

  has_attached_file :document,
                    path: ":rails_root/uploads/documents/:customer_evaluation/:id_partition_:basename.:extension",
                    url: "/uploads/documents/:customer_evaluation/:id_partition_:basename.:extension"
  validates_format_of :document_file_name, :with => /\.(docx|doc|pdf|xls|xlsx|csv)/i, :allow_nil => true

  Paperclip.interpolates :customer_evaluation do |attachment, style|
    evaluation = attachment.instance.evaluation_result.evaluation
    "#{evaluation.customer.id}_#{evaluation.id}"
  end


  scope :assets, ->{
      where("evaluation_result_files.asset_content_type IS NOT NULL")
  }
  scope :documents, ->{
      where("evaluation_result_files.document_content_type IS NOT NULL")
  }

end
