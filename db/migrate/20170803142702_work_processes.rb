class WorkProcesses < ActiveRecord::Migration
	def change
		create_table :work_processes do |t|
			t.string :name
		end
	end
end
