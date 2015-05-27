require 'uri'
require './lib/assets/http_client'
require './lib/assets/uri_generator'


class Tasks::EnvironmentSensorDataCollectionTask
  def self.execute
    # uri
    uri = UriGenerator.aircasting_average('RHT03', 'Temperature', 'F')
    query = Hash[URI::decode_www_form(uri.query)]

    # request header
    request_header = {}
    request_header['Accept'] = 'application/json'

    json = HttpClient.get_json(uri.to_s, request_header)

    sensor_id = 0
#    case query['q[measurement_type]']
#    when 'Temperature'
#      sensor_type = 1
#    else
#      return
#    end

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
      #date_string = (sensor_json['timestamp']) ? sensor_json['timestamp'] : nil
      #wheel_data.timestamp = DateTime.parse(date_string) if date_string != nil
      sensor_data.timestamp = DateTime.now

      sensor_data.save if sensor_data.valid?
    end

  end
end
