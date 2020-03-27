class PdfAssetsChange < ActiveRecord::Migration
  def change
    rename_column :pdf_assets, :report_type, :key
    add_column :pdf_assets, :chart_type, :string
  end
end
