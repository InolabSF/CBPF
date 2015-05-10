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
#    request_header['Accept'] = 'application/json'
#    request_header['Referer'] = 'http://aircasting.org/map'
#    request_header['User-Agent'] = 'Chrome/42.0.2311.90'
#    request_header['X-Requested-With'] = 'XMLHttpRequest'
#    request_header['Accept-Encoding'] = 'gzip'
#    request_header['Accept-Language'] = 'en-US'

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
      sensor_value = SensorData.new
      # sensor id
      sensor_value.sensor_id = sensor_id
      # sensor value
      sensor_value.value = sensor_json['value'] if sensor_json['value']
      # latitude
      north = (sensor_json['north']) ? sensor_json['north'] : null
      south = (sensor_json['south']) ? sensor_json['south'] : null
      sensor_value.lat = (north + south) / 2.0 if north && south
      # longitude
      west = (sensor_json['west']) ? sensor_json['west'] : null
      east = (sensor_json['east']) ? sensor_json['east'] : null
      sensor_value.long = (west + east) / 2.0 if west && east
      # user id
      sensor_value.user_id = sensor_json['user_id'] if sensor_json['user_id']
      # timestamp
      #date_string = sensor_json['timestamp'] if sensor_json['timestapm']
      #sensor_value.timestamp = DateTime.httpdate(date_string)
      sensor_value.timestamp = DateTime.now

      if sensor_value.valid?
        sensor_value.save
      end
    end

  end
end
