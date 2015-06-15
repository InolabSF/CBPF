require './lib/assets/math_utility'


class SensorController < ApplicationController

=begin
  @apiVersion 0.1.0

  @apiGroup Sensor
  @api {get} /sensor/data
  @apiName SensorData
  @apiDescription get environmental sensor data close to your location

  @apiParam {Number} lat                        Mandatory latitude
  @apiParam {Number} long                       Mandatory longitude
  @apiParam {Number} radius                     Mandatory radius of miles to search
  @apiParam {Number} sensor_type                Mandatory sensor type
  @apiParam {example} sensor_type.humidity      1
  @apiParam {example} sensor_type.co            2
  @apiParam {example} sensor_type.co2           3
  @apiParam {example} sensor_type.no2           4
  @apiParam {example} sensor_type.pm25          5
  @apiParam {example} sensor_type.noise         6
  @apiParam {example} sensor_type.temperature   7
  @apiParam {example} sensor_type.light         8

  @apiParamExample {json} Request-Example:
    {
      "lat": 37.76681832250885,
      "long": -122.4207906162038,
      "radius": 3.0,
      "sensor_type": 1, // humidity
    }

  @apiSuccess {Number} id SensorData ID
  @apiSuccess {Number} value SensorData value
  @apiSuccess {Number} sensor_id Sensor ID
  @apiSuccess {Number} lat Latitude
  @apiSuccess {Number} long Longitude
  @apiSuccess {Number} user_id User ID
  @apiSuccess {String} timestamp Timestamp

  @apiSuccessExample {json} Success-Response:
    {
      "sensor_datas": [
        {
          "created_at": "2015-05-07T01:25:39.744Z",
          "id": 1,
          "lat": 37.792097317369965,
          "long": -122.43528085596421,
          "sensor_id": 0,
          "timestamp": "2015-05-07T01:25:39.738Z",
          "updated_at": "2015-05-07T01:25:39.744Z",
          "user_id": null,
          "value": 57.23776223776224
        }
      ]
    }
=end
  def data
    # get latitude, longitude
    lat = params[:lat].to_f
    long = params[:long].to_f
    radius = params[:radius].to_f
    sensor_type = params[:sensor_type].to_i

    # calculate distance of latitude and longitude degree
    lat_degree = MathUtility.get_lat_degree(lat, long, radius)
    long_degree = MathUtility.get_long_degree(lat, long, radius)
    is_return_json = !(lat_degree == 0 || long_degree == 0)

    #start_date = 1.month.ago
    #end_date = 0.month.ago

    # response
    if is_return_json
      datas = SensorData.where(
        sensor_id: sensor_type,
        lat: (lat-lat_degree)..(lat+lat_degree),
        long: (long-long_degree)..(long+long_degree)
        #timestamp: DateTime.new(start_date.year, start_date.month, 1)..DateTime.new(end_date.year, end_date.month, 1)
      )
      json = Jbuilder.encode do |j|
        j.sensor_datas(datas)
      end
      render json: json
    else
      render json: { }
    end
  end

end
