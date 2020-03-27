class AddCustomerCodeToCompany < ActiveRecord::Migration[5.2]
  def change
    execute "CREATE SEQUENCE company_customer_code_seq INCREMENT BY 1 MINVALUE 150000 MAXVALUE 159999"
    execute "ALTER TABLE companies ADD COLUMN customer_code INT DEFAULT NEXTVAL('company_customer_code_seq')"
  end
end
