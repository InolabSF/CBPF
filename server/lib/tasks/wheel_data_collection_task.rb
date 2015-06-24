require 'csv'


class Tasks::WheelDataCollectionTask

  def self.execute

    # read csv files
    file_count = 0
    file_name = "public/test_#{file_count}.csv"
    while File.exist?(file_name) do
      param_count = 0
      reader = CSV.open(file_name, 'r', :col_sep => ",")
      reader.each do |row|
        param_count = param_count + 1
        next if param_count < 38
        wheel_data = WheelData.new
        wheel_data.timestamp = DateTime.strptime(row[0],'%Q')
        wheel_data.lat = row[1]
        wheel_data.long = row[2]
        wheel_data.torque = row[13]
        wheel_data.velocity = row[3]
        wheel_data.accel = row[4]
        wheel_data.save if wheel_data.valid?
      end
      file_count = file_count + 1
      file_name = "public/test_#{file_count}.csv"
    end

    puts 'Tasks::WheelDataCollectionTask#execute done'
  end

end
