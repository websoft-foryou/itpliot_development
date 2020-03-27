class AddProductExamplesToServices < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :product_examples, :string
    Service.add_translation_fields! :product_examples => :string
  end
end
