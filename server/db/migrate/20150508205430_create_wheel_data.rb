class CreateWheelData < ActiveRecord::Migration
  def change
    create_table :wheel_data do |t|
      t.integer :data_type
      t.float :value
      t.float :lat
      t.float :long
      t.datetime :timestamp

      t.timestamps null: false
    end
  end
end
