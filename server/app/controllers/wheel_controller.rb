require './lib/assets/math_utility'


class WheelController < ApplicationController

  skip_before_filter :verify_authenticity_token

=begin
  @apiVersion 0.1.0

  @apiGroup Wheel
  @api {get} /wheel/data
  @apiName WheelData(GET)
  @apiDescription get wheel sensor data or something close to your location

  @apiParam {Number} lat                                                   Mandatory latitude
  @apiParam {Number} long                                                  Mandatory longitude
  @apiParam {Number} radius                                                Mandatory radius of miles to search
  @apiParam {Number} data_type                                             Mandatory data type
  @apiParam {example} data_type.sensorData_phone_applicationState          1
  @apiParam {example} data_type.sensorData_phone_altitude                  2
  @apiParam {example} data_type.sensorData_phone_networkState              3
  @apiParam {example} data_type.sensorData_phone_speed                     4
  @apiParam {example} data_type.sensorData_phone_gpsHorizontalAccuracy     5
  @apiParam {example} data_type.sensorData_phone_gpsVerticalAccuracy       6
  @apiParam {example} data_type.sensorData_phone_batteryLevel              7
  @apiParam {example} data_type.sensorData_phone_gpsStrength               8
  @apiParam {example} data_type.wheelData_speed                            9
  @apiParam {example} data_type.wheelData_slope                            10
  @apiParam {example} data_type.wheelData_energyEfficiency                 11
  @apiParam {example} data_type.wheelData_totalOdometer                    12
  @apiParam {example} data_type.wheelData_tripOdometer                     13
  @apiParam {example} data_type.wheelData_tripAverageSpeed                 14
  @apiParam {example} data_type.wheelData_tripEnergyEfficiency             15
  @apiParam {example} data_type.wheelData_motorTemperature                 16
  @apiParam {example} data_type.wheelData_motorDriveTemperature            17
  @apiParam {example} data_type.wheelData_riderTorque                      18
  @apiParam {example} data_type.wheelData_riderPower                       19
  @apiParam {example} data_type.wheelData_batteryCharge                    20
  @apiParam {example} data_type.wheelData_batteryHealth                    21
  @apiParam {example} data_type.wheelData_batteryPower                     22
  @apiParam {example} data_type.wheelData_batteryVoltage                   23
  @apiParam {example} data_type.wheelData_batteryCurrent                   24
  @apiParam {example} data_type.wheelData_batteryTemperature               25
  @apiParam {example} data_type.wheelData_batteryTimeToFull                26
  @apiParam {example} data_type.wheelData_batteryTimeToEmpty               27
  @apiParam {example} data_type.wheelData_batteryRange                     28
  @apiParam {example} data_type.wheelData_rawDebugData                     29
  @apiParam {example} data_type.wheelData_batteryPowerNormalized           30

  @apiParamExample {json} Request-Example:
    {
      "lat": 37.76681832250885,
      "long": -122.4207906162038,
      "radius": : 3.0,
      "data_type": 9, // data_type.wheelData.speed
    }

  @apiSuccess {Number} id WheelData ID
  @apiSuccess {Number} data_type WheelData type
  @apiSuccess {Number} value WheelData value
  @apiSuccess {Number} lat Latitude
  @apiSuccess {Number} long Longitude
  @apiSuccess {Number} user_id User ID
  @apiSuccess {String} timestamp Timestamp

  @apiSuccessExample {json} Success-Response:
    {
      "wheel_datas": [
        {
          "created_at": "2015-05-07T01:25:39.744Z",
          "id": 1,
          "data_type": 1,
          "lat": 37.792097317369965,
          "long": -122.43528085596421,
          "timestamp": "2015-05-07T01:25:39.738Z",
          "updated_at": "2015-05-07T01:25:39.744Z",
          "user_id": null,
          "value": 13.555334
        }
      ]
    }
=end
=begin
  @apiVersion 0.1.0

  @apiGroup Wheel
  @api {post} /wheel/data
  @apiName WheelData(POST)
  @apiDescription post wheel sensor data or something

  @apiParam {Hash} wheel_datas                                      Mandatory
  @apiParam {Array} wheel_datas.array                               Mandatory
  @apiParam {Hash} wheel_datas.array.wheel_data                     Mandatory
  @apiParam {Number} wheel_datas.array.wheel_data.data_type         Mandatory data type
  @apiParam {Number} wheel_datas.array.wheel_data.value             Mandatory value
  @apiParam {Number} wheel_datas.array.wheel_data.lat               Mandatory latitude
  @apiParam {Number} wheel_datas.array.wheel_data.long              Mandatory longitude
  @apiParam {Number} wheel_datas.array.wheel_data.user_id           Mandatory user id
  @apiParam {String} wheel_datas.array.wheel_data.timestamp         Mandatory timestamp

  @apiParamExample {json} Request-Example:
    {
      "wheel_datas": [
        {
          "data_type": 9,
          "lat": 37.76681832250885,
          "long": -122.4207906162038,
          "user_id": 1,
          "timestamp": "2015-05-07T01:25:39.738Z",
          "value": 13.555334
        }
      ]
    }

  @apiSuccess {Number} application_code 200

  @apiSuccessExample {json} Success-Response:
    {
      "application_code": 200
    }
=end
  def data
    is_return_json = false

    # GET
    if request.get?
      # get latitude, longitude
      lat = params[:lat].to_f
      long = params[:long].to_f
      radius = params[:radius].to_i
      data_type = params[:data_type].to_i

      # calculate distance of latitude and longitude degree
      lat_degree = MathUtility.get_lat_degree(lat, long, radius)
      long_degree = MathUtility.get_long_degree(lat, long, radius)
      is_return_json = !(lat_degree == 0 || long_degree == 0)

      #start_date = 1.month.ago
      #end_date = 0.month.ago

      # response
      if is_return_json
        datas = WheelData.where(
          data_type: data_type,
          lat: (lat-lat_degree)..(lat+lat_degree),
          long: (long-long_degree)..(long+long_degree)
          #long: (long-long_degree)..(long+long_degree),
          #timestamp: DateTime.new(start_date.year, start_date.month, 1)..DateTime.new(end_date.year, end_date.month, 1)
        )
        json = Jbuilder.encode do |j|
          j.wheel_datas(datas)
        end

        # response
        render json: json
      end

    # POST
    elsif request.post?
      wheel_jsons = []
      wheel_jsons = params[:wheel_datas] if params[:wheel_datas].is_a?(Array)

      wheel_jsons.each do |wheel_json|
        wheel_data = WheelData.new
        # data_type
        wheel_data.data_type = wheel_json['data_type'].to_i
        # value
        wheel_data.value = wheel_json['value'] if wheel_json['value']
        # latitude
        wheel_data.lat = wheel_json['lat'].to_f
        # longitude
        wheel_data.long = wheel_json['long'].to_f
        # user id
        wheel_data.user_id = wheel_json['user_id'] if wheel_json['user_id']
        # timestamp
        date_string = (wheel_json['timestamp']) ? wheel_json['timestamp'] : nil
        wheel_data.timestamp = DateTime.parse(date_string) if date_string != nil

        if wheel_data.valid?
          wheel_data.save
          is_return_json = true
        end
      end

      # response
      render json: { "application_code" => 200 } if is_return_json
    end

    # response
    if !is_return_json
      render json: { }
    end
  end

end
