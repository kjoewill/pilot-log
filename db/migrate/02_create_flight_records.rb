class CreateFlightRecords < ActiveRecord::Migration
  def change
    create_table :flight_records do |t|
      t.date :date
      t.string :aircraft_type
      t.string :from
      t.string :to
      t.string :remarks
      t.integer :num_landings
      t.integer :duration
      t.integer :user_id
    end
  end
end
