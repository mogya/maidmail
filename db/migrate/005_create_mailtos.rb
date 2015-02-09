class CreateMailtos < ActiveRecord::Migration
	def self.up
		create_table :mailtos do |t|
			t.string :mailto
			t.timestamps
		end
	end

	def self.down
		drop_table :mailtos
	end
end
