require 'csv'


class Tasks::WheelLocationCollectionTask

  def self.execute
    param_count = 0

    reader = CSV.open("public/test.csv", 'r', :col_sep => ",")
    reader.each do |row|
      param_count = param_count + 1
      next if param_count < 38
      wheel_location = WheelLocation.new
      wheel_location.timestamp = DateTime.strptime(row[0],'%Q')
      wheel_location.lat = row[1]
      wheel_location.long = row[2]
      wheel_location.torque = row[13]
      wheel_location.velocity = row[3]
      wheel_location.accel = row[4]
      wheel_location.save if wheel_location.valid?
    end
  end

end
