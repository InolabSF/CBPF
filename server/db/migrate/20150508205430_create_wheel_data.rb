class CreateWheelData < ActiveRecord::Migration
  def change
    create_table :wheel_data do |t|
      t.integer :type
      t.float :value
      t.float :lat
      t.float :long
      t.float :user_id
      t.datetime :timestamp

      t.timestamps null: false
    end
  end
end
