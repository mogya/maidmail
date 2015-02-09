class CreatePasswdResetRequests < ActiveRecord::Migration
  def self.up
		create_table :passwd_reset_requests do |t|
			t.integer :user_id
			t.string :key
			t.boolean :used, :default=>false
			t.timestamps
		end
  end

  def self.down
    drop_table :passwd_reset_requests
  end
end
