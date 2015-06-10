class CreateCrimeData < ActiveRecord::Migration
  def change
    create_table :crime_data do |t|
      t.string :category
      t.string :desc
      t.string :resolution
      t.float :lat
      t.float :long
      t.datetime :timestamp

      t.timestamps null: false
    end
  end
end
