class CreateWheelLocations < ActiveRecord::Migration
  def change
    create_table :wheel_locations do |t|
      t.float :lat
      t.float :long
      t.float :torque
      t.float :velocity
      t.float :accel
      t.datetime :timestamp

      t.timestamps null: false
    end
  end
end
