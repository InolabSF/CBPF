require 'csv'
require 'kconv'

WHEEL_DATA_TYPE_TORQUE = 18
WHEEL_DATA_TYPE_ACCEL = 31
WHEEL_DATA_TYPES = [WHEEL_DATA_TYPE_TORQUE, WHEEL_DATA_TYPE_ACCEL]
WHEEL_ROW_INDEX = {WHEEL_DATA_TYPE_TORQUE => 13, WHEEL_DATA_TYPE_ACCEL => 4}

class Tasks::WheelDataCollectionTask

#  def self.import_csv(csv_file)
#    csv_text = csv_file.read
#    CSV.parse(Kconv.toutf8(csv_text)) do |row|
#      wheel_data = WheelData.new
#      wheel_data.timestamp = DateTime.strptime(row[0],'%Q')
#      wheel_data.lat = row[1]
#      wheel_data.long = row[2]
#      wheel_data.value = row[WHEEL_ROW_INDEX[data_type]]
#      wheel_data.data_type = data_type
#      wheel_data.save if wheel_data.valid?
#    end
#  end

  def self.execute

    # read csv files
    file_name = (Rails.env.production?) ? Rails.root.join("assets/csvs/test_0.csv") : "public/test_0.csv"
    if File.exist?(file_name)
      param_count = 0
      reader = CSV.open(file_name, 'r', :col_sep => ",")
      reader.each do |row|
        param_count = param_count + 1
        next if param_count < 38

        WHEEL_DATA_TYPES.each do |data_type|
          wheel_data = WheelData.new
          wheel_data.timestamp = DateTime.strptime(row[0],'%Q')
          wheel_data.lat = row[1]
          wheel_data.long = row[2]
          wheel_data.value = row[WHEEL_ROW_INDEX[data_type]]
          wheel_data.data_type = data_type
          wheel_data.save if wheel_data.valid?
        end
      end
    else
      puts file_name + ' doesn\'t exist'
    end

    puts 'Tasks::WheelDataCollectionTask#execute done'

  end

  def self.executeAll

    # read csv files
    file_count = 0
    file_name = (Rails.env.production?) ? Rails.root.join("assets/csvs/test_#{file_count}.csv") : "public/test_#{file_count}.csv"
    while File.exist?(file_name) do
      param_count = 0
      reader = CSV.open(file_name, 'r', :col_sep => ",")
      reader.each do |row|
        param_count = param_count + 1
        next if param_count < 38

        WHEEL_DATA_TYPES.each do |data_type|
          wheel_data = WheelData.new
          wheel_data.timestamp = DateTime.strptime(row[0],'%Q')
          wheel_data.lat = row[1]
          wheel_data.long = row[2]
          wheel_data.value = row[WHEEL_ROW_INDEX[data_type]]
          wheel_data.data_type = data_type
          wheel_data.save if wheel_data.valid?
        end
      end
      file_count = file_count + 1
      file_name = (Rails.env.production?) ? Rails.root.join("assets/csvs/test_#{file_count}.csv") : "public/test_#{file_count}.csv"
    end

    puts 'Tasks::WheelDataCollectionTask#executeAll done'
  end

end
