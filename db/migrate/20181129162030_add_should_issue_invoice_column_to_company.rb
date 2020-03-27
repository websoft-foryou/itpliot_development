class AddShouldIssueInvoiceColumnToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :should_issue_invoice, :boolean, default: false
  end
end
