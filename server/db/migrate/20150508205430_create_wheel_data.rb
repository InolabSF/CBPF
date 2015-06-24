class CreateWheelData < ActiveRecord::Migration
  def change
    create_table :wheel_data do |t|
      t.float :torque
      t.float :velocity
      t.float :accel
      t.float :lat
      t.float :long
      t.datetime :timestamp

      t.timestamps null: false
    end
  end
end
