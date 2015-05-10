class CreateSensorData < ActiveRecord::Migration
  def change
    create_table :sensor_data do |t|
      t.integer :sensor_id
      t.float :value
      t.float :lat
      t.float :long
      t.integer :user_id
      t.datetime :timestamp

      t.timestamps null: false
    end
  end
end
