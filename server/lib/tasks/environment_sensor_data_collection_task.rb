require 'uri'
require './lib/assets/http_client'
require './lib/assets/uri_generator'


class Tasks::EnvironmentSensorDataCollectionTask
  def self.execute_all
    self.execute_aircasting(Date.new(2011, 1, 1), Date.today)
    puts 'Tasks::EnvironmentSensorDataCollectionTask#execute_all done'
  end

  def self.execute_three_days_ago
    self.execute_aircasting(3.days.ago, 2.days.ago)
    puts 'Tasks::EnvironmentSensorDataCollectionTask#execute_three_days_ago done'
  end

  def self.execute_aircasting(date_from, date_to)
    sensor_params = [
      # Humidity
      { 'type' => 1, 'sensor_name' => 'AirBeam-RH', 'measurement_type' => 'Humidity', 'unit_symbol' => '%' },
      # CO
      # CO2
      # NO2
      # PM2.5
      { 'type' => 5, 'sensor_name' => 'AirBeam-PM', 'measurement_type' => 'Particulate Matter', 'unit_symbol' => 'µg/m³' },
      # Sound Level
      { 'type' => 6, 'sensor_name' => 'Phone Microphone', 'measurement_type' => 'Sound Level', 'unit_symbol' => 'dB' },
      # Temperature
      { 'type' => 7, 'sensor_name' => 'AirBeam-F', 'measurement_type' => 'Temperature', 'unit_symbol' => 'F' }
    ]

    sensor_params.each do |sensor_param|
      uri = UriGenerator.aircasting_average(sensor_param['sensor_name'], sensor_param['measurement_type'], sensor_param['unit_symbol'], date_from, date_to)

      query = Hash[URI::decode_www_form(uri.query)]
      request_header = {}
      json = HttpClient.get_json(uri.to_s, request_header)
=begin
    json example
    [
      {
        "value" : 75.0,
        "west" : -122.40625000000124,
        "east" : -122.40375000000124,
        "south" : 37.77893117421314,
        "north" : 37.78419763147588
      }
    ]
=end
      next if json == nil

      # TODO make sensor table
      sensor_id = sensor_param['type']

      # create sensor value
      json.each do |sensor_json|
        sensor_data = SensorData.new
        # sensor id
        sensor_data.sensor_id = sensor_id
        # sensor value
        sensor_data.value = sensor_json['value'] if sensor_json['value']
        # latitude
        north = (sensor_json['north']) ? sensor_json['north'] : null
        south = (sensor_json['south']) ? sensor_json['south'] : null
        sensor_data.lat = (north + south) / 2.0 if north && south
        # longitude
        west = (sensor_json['west']) ? sensor_json['west'] : null
        east = (sensor_json['east']) ? sensor_json['east'] : null
        sensor_data.long = (west + east) / 2.0 if west && east
        # user id
        sensor_data.user_id = sensor_json['user_id'] if sensor_json['user_id']
        # timestamp
        sensor_data.timestamp = date_from

        sensor_data.save if sensor_data.valid?
      end
    end
  end
end
