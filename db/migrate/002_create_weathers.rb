class CreateWeathers < ActiveRecord::Migration
  def self.up
    create_table :weathers do |t|
      t.integer :city_id
      t.datetime :rss_date
      t.text :weather
      t.integer :high_temperature
      t.integer :low_temperature
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :weathers
  end
end
