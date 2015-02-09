class CreateUsers < ActiveRecord::Migration
	def self.up
		create_table :users do |t|
			t.string :mail
			t.string :password
			t.string :mailto
			t.string :morningMailTime
			t.integer :notifybefore
			t.string :calendarFeedUri
			t.string :calendarToken
			t.integer :city_id

			t.string :ext1
			t.string :ext2
			t.timestamps
		end
	end

	def self.down
		drop_table :users
	end
end
