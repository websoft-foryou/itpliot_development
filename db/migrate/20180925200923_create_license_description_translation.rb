class CreateLicenseDescriptionTranslation < ActiveRecord::Migration[5.2]
  class License < ActiveRecord::Base
    translates :description
  end
  def change
    License.create_translation_table! :description => :string
  end
end
