require './lib/assets/math_utility'
require 'csv'
require 'kconv'


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
  @apiParam {Number} data_type                                             Mandatory data type from copenhagen wheel
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
  @apiParam {example} data_type.wheelData_acceleration                     31
  @apiParam {Number} max                                                   Optional smaller accel datas will return (either maxValue or minValue needs)
  @apiParam {Number} min                                                   Optional bigger torque datas will return (either maxValue or minValue needs)

  @apiParamExample {json} Request-Example (torque):
    {
      "lat": 37.76681832250885,
      "long": -122.4207906162038,
      "data_type": 18, // wheelData.riderTorque
      "radius": 3.0,
      "max": -2.0
    }

  @apiParamExample {json} Request-Example (acceleration):
    {
      "lat": 37.76681832250885,
      "long": -122.4207906162038,
      "data_type": 31, // wheelData.acceleration
      "radius": 3.0,
      "min": 20.0
    }

  @apiSuccess {Number} data_type data type from copenhagen wheel
  @apiSuccess {Number} value value
  @apiSuccess {Number} lat Latitude
  @apiSuccess {Number} long Longitude
  @apiSuccess {String} timestamp Timestamp

  @apiSuccessExample {json} Success-Response:
    {
      "wheel_datas": [
        {
          "created_at": "2015-05-07T01:25:39.744Z",
          "id": 1,
          "data_type": 18,
          "value": 1.0353324,
          "lat": 37.792097317369965,
          "long": -122.43528085596421,
          "timestamp": "2015-05-07T01:25:39.738Z",
          "updated_at": "2015-05-07T01:25:39.744Z",
        }
      ]
    }
=end
  def data
    is_return_json = false

    # get latitude, longitude
    data_type = (params[:data_type]) ? params[:data_type].to_i : nil
    lat = (params[:lat]) ? params[:lat].to_f : nil
    long = (params[:long]) ? params[:long].to_f : nil
    radius = (params[:radius]) ? params[:radius].to_i : nil
    max = (params[:max]) ? params[:max].to_f : nil
    min = (params[:min]) ? params[:min].to_f : nil

    # calculate distance of latitude and longitude degree
    lat_degree = MathUtility.get_lat_degree(lat, long, radius)
    long_degree = MathUtility.get_long_degree(lat, long, radius)
    is_return_json = (data_type) && !(lat_degree == 0 || long_degree == 0) && (max || min)

    #start_date = 1.month.ago
    #end_date = 0.month.ago

    # response
    if is_return_json
      #datas = WheelData.where(
      #  lat: (lat-lat_degree)..(lat+lat_degree),
      #  long: (long-long_degree)..(long+long_degree)
      #  #timestamp: DateTime.new(start_date.year, start_date.month, 1)..DateTime.new(end_date.year, end_date.month, 1)
      #)

      where = nil
      if max && min
        where = "lat > #{lat-lat_degree} and lat < #{lat+lat_degree} and long > #{long-long_degree} and long < #{long+long_degree} and value < #{max} and value > #{min}"
      elsif max
        where = "lat > #{lat-lat_degree} and lat < #{lat+lat_degree} and long > #{long-long_degree} and long < #{long+long_degree} and value < #{max}"
      elsif min
        where = "lat > #{lat-lat_degree} and lat < #{lat+lat_degree} and long > #{long-long_degree} and long < #{long+long_degree} and value > #{min}"
      end

      json = nil
      if where
        datas = WheelData.where(where)
        json = Jbuilder.encode do |j|
          j.wheel_datas(datas)
        end
      else
        json = { }
      end

      # response
      render json: json
    end

    # response
    if !is_return_json
      render json: { }
    end
  end

  def location
    is_return_json = false

    # get latitude, longitude
    lat = params[:lat].to_f
    long = params[:long].to_f
    radius = params[:radius].to_i

    # calculate distance of latitude and longitude degree
    lat_degree = MathUtility.get_lat_degree(lat, long, radius)
    long_degree = MathUtility.get_long_degree(lat, long, radius)
    is_return_json = !(lat_degree == 0 || long_degree == 0)

    # response
    if is_return_json
      datas = WheelLocation.where(
        lat: (lat-lat_degree)..(lat+lat_degree),
        long: (long-long_degree)..(long+long_degree)
      )
      json = Jbuilder.encode do |j|
        j.wheel_locations(datas)
      end

      # response
      render json: json
    end

    # response
    if !is_return_json
      render json: { }
    end
  end

  def torque
    is_return_json = false

    # get latitude, longitude
    lat = params[:lat].to_f
    long = params[:long].to_f
    radius = params[:radius].to_i

    # calculate distance of latitude and longitude degree
    lat_degree = MathUtility.get_lat_degree(lat, long, radius)
    long_degree = MathUtility.get_long_degree(lat, long, radius)
    is_return_json = !(lat_degree == 0 || long_degree == 0)

    # response
    if is_return_json
      datas = WheelLocation.where(
        torque: (15.0)..(1000.0),
        lat: (lat-lat_degree)..(lat+lat_degree),
        long: (long-long_degree)..(long+long_degree)
      )
      json = Jbuilder.encode do |j|
        j.wheel_torques(datas)
      end

      # response
      render json: json
    end

    # response
    if !is_return_json
      render json: { }
    end
  end

  def accel
    is_return_json = false

    # get latitude, longitude
    lat = params[:lat].to_f
    long = params[:long].to_f
    radius = params[:radius].to_i

    # calculate distance of latitude and longitude degree
    lat_degree = MathUtility.get_lat_degree(lat, long, radius)
    long_degree = MathUtility.get_long_degree(lat, long, radius)
    is_return_json = !(lat_degree == 0 || long_degree == 0)

    # response
    if is_return_json
      datas = WheelLocation.where(
        accel: (-100.0)..(-2.0),
        lat: (lat-lat_degree)..(lat+lat_degree),
        long: (long-long_degree)..(long+long_degree)
      )
      json = Jbuilder.encode do |j|
        j.wheel_accels(datas)
      end

      # response
      render json: json
    end

    # response
    if !is_return_json
      render json: { }
    end
  end

  def accel_torque
    is_return_json = false

    # get latitude, longitude
    lat = params[:lat].to_f
    long = params[:long].to_f
    radius = params[:radius].to_i

    # calculate distance of latitude and longitude degree
    lat_degree = MathUtility.get_lat_degree(lat, long, radius)
    long_degree = MathUtility.get_long_degree(lat, long, radius)
    is_return_json = !(lat_degree == 0 || long_degree == 0)

    # response
    if is_return_json
      accel_datas = WheelLocation.where(
        accel: (-100.0)..(-2.0),
        lat: (lat-lat_degree)..(lat+lat_degree),
        long: (long-long_degree)..(long+long_degree)
      )
      torque_datas = WheelLocation.where(
        torque: (15.0)..(1000.0),
        lat: (lat-lat_degree)..(lat+lat_degree),
        long: (long-long_degree)..(long+long_degree)
      )
      location_datas = WheelLocation.where(
        lat: (lat-lat_degree)..(lat+lat_degree),
        long: (long-long_degree)..(long+long_degree)
      )
      json = Jbuilder.encode do |j|
        j.wheel_accels(accel_datas)
        j.wheel_torques(torque_datas)
        j.wheel_locations(location_datas)
      end

      # response
      render json: json
    end

    # response
    if !is_return_json
      render json: { }
    end
  end


  def import_wheel
    csv_text = params[:csv_file].read

    #WHEEL_DATA_TYPE_TORQUE = 18
    #WHEEL_DATA_TYPE_ACCEL = 31
    #WHEEL_DATA_TYPES = [WHEEL_DATA_TYPE_TORQUE, WHEEL_DATA_TYPE_ACCEL]
    #WHEEL_ROW_INDEX = {WHEEL_DATA_TYPE_TORQUE => 13, WHEEL_DATA_TYPE_ACCEL => 4}

    CSV.parse(Kconv.toutf8(csv_text)) do |row|
      wheel_data = WheelData.new
      #wheel_data.timestamp = DateTime.strptime(row[0],'%Q')
      wheel_data.lat = row[1]
      wheel_data.long = row[2]
      wheel_data.value = row[13]
      wheel_data.data_type = 18
      wheel_data.save if wheel_data.valid?
    end

    CSV.parse(Kconv.toutf8(csv_text)) do |row|
      wheel_data = WheelData.new
      #wheel_data.timestamp = DateTime.strptime(row[0],'%Q')
      wheel_data.lat = row[1]
      wheel_data.long = row[2]
      wheel_data.value = row[4]
      wheel_data.data_type = 31
      wheel_data.save if wheel_data.valid?
    end

    render json: { }
  end

  def stub_data
    wheel_jsons = params[:wheel_datas]
    render json: { :application_code => 400 } unless wheel_jsons

    wheel_jsons.each do |wheel_json|
      wheel_data = WheelData.new
      next unless wheel_json[:timestamp]
      wheel_data.timestamp = DateTime.strptime(wheel_json[:timestamp], '%Y-%m-%dT%H:%M:%S.%LZ')
      wheel_data.lat = wheel_json[:lat]
      wheel_data.long = wheel_json[:long]
      wheel_data.value = wheel_json[:value]
      wheel_data.data_type = wheel_json[:data_type]
      wheel_data.save if wheel_data.valid?
    end

    render json: { :application_code => 200 }
  end

end
