class DefaultParentCompany < ActiveRecord::Migration
  def change
    add_column :companies, :default_parent, :boolean, default: false, null: false
    c = Company.admin.where("companies.name ILIKE '%netcos%'").first || Company.admin.order(:id).first
    c.present? && c.update_attribute(:default_parent, true)
  end
end
