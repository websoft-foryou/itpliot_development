class InitializeSequenceEmployees < ActiveRecord::Migration[5.2]
  def change
    Company.customer.each do |customer|
      seq = 1
      customer.employees.each do |employee|
        employee.seq = seq
        employee.save!
        seq += 1
      end
    end
  end
end
