class CreateServiceRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :service_requests do |t|
      t.string :service_name
      t.string :description
      t.string :prod_example
      t.string :company_name
      t.string :contact
      t.string :email
      t.string :telephone
      t.string :reason

      t.timestamps
    end
  end
end
