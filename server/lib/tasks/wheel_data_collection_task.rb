require 'csv'


class Tasks::WheelDataCollectionTask

  def self.execute
'1' : sensorData.phone.applicationState
'2' : sensorData.phone.altitude
'3' : sensorData.phone.networkState
'4' : sensorData.phone.speed
'5' : sensorData.phone.gpsHorizontalAccuracy
'6' : sensorData.phone.gpsVerticalAccuracy
'7' : sensorData.phone.batteryLevel
'8' : sensorData.phone.gpsStrength
'9' : wheelData.speed
'10' : wheelData.slope
'11' : wheelData.energyEfficiency
'12' : wheelData.totalOdometer
'13' : wheelData.tripOdometer
'14' : wheelData.tripAverageSpeed
'15' : wheelData.tripEnergyEfficiency
'16' : wheelData.motorTemperature
'17' : wheelData.motorDriveTemperature
'18' : wheelData.riderTorque
'19' : wheelData.riderPower
'20' : wheelData.batteryCharge
'21' : wheelData.batteryHealth
'22' : wheelData.batteryPower
'23' : wheelData.batteryVoltage
'24' : wheelData.batteryCurrent
'25' : wheelData.batteryTemperature
'26' : wheelData.batteryTimeToFull
'27' : wheelData.batteryTimeToEmpty
'28' : wheelData.batteryRange
'29' : wheelData.rawDebugData
'30' : wheelData.batteryPowerNormalized
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
        wheel_data.accel = row[4]
        wheel_data.save if wheel_data.valid?
      end
      file_count = file_count + 1
      file_name = "public/test_#{file_count}.csv"
    end

    puts 'Tasks::WheelDataCollectionTask#execute done'
  end

end
