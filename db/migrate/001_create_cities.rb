class CreateCities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.string :name
      t.string :area1
      t.string :area2
      t.string :rss_uri
      t.string :rss_type
      t.integer :pos_latitude
      t.integer :pos_longitude

      t.timestamps
    end
	end
  def self.down
    drop_table :cities
  end
end
