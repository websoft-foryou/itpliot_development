class WorkProcessesTranslations < ActiveRecord::Migration
	class WorkProcess < ActiveRecord::Base
		translates :name
	end
	def change
		WorkProcess.create_translation_table! :name => :string
	end
end
