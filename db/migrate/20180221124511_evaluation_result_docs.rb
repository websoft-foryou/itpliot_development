class EvaluationResultDocs < ActiveRecord::Migration
  def change
    add_column :evaluation_result_files, :document_file_name, :string
    add_column :evaluation_result_files, :document_content_type, :string
    add_column :evaluation_result_files, :document_updated_at, :string
  end
end
