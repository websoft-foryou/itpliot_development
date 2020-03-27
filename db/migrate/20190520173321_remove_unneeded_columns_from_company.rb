class RemoveUnneededColumnsFromCompany < ActiveRecord::Migration[5.2]
  def change
    remove_column :companies, :should_issue_invoice
    remove_column :companies, :will_continue_plan
  end
end
