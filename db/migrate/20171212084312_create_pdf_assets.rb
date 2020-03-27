class CreatePdfAssets < ActiveRecord::Migration
  def change
    create_table :pdf_assets do |t|
      t.integer :evaluation_id, :null => false
      t.string :report_type, :null => false
      t.text :img_string, :null => false
    end
  end
end
