class SensorController < ApplicationController

=begin
  @apiVersion 0.1.0

  @apiGroup Sensor
  @api {get} /sensor/data
  @apiName SensorData
  @apiDescription get environmental sensor data close to your location

  @apiParam {Number} lat                        Mandatory latitude
  @apiParam {Number} long                       Mandatory longitude
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
      "long": -122.4207906162038
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
    is_return_json = (lat.is_a?(Float) && long.is_a?(Float)) ? true : false

    # calculate degree of 3 mile
    lat_3_mile = 0.01448293736501 * 3.0
    long_3_mile = 0
    if is_return_json
      begin
        long_3_mile = 1.0 / 7.03360549391553 * Math.cos(lat * 0.017453293).abs * 3.0
      rescue ZeroDivisionError
        is_return_json = false
      end
    end

    # response
    if is_return_json
      sonsor_datas = SensorData.where(lat: (lat-lat_3_mile)..(lat+lat_3_mile), long: (long-long_3_mile)..(long+long_3_mile))
      json = Jbuilder.encode do |j|
        j.sensor_datas(sonsor_datas)
      end
      render json: json
    else
      render json: { }
    end
  end

end
