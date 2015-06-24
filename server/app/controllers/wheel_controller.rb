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
  @apiParam {Number} maxAccel                                              Optional smaller accel datas will return (maxAccel or minTorque needs)
  @apiParam {Number} minTorque                                             Optional bigger torque datas will return (maxAccel or minTorque needs)

  @apiParamExample {json} Request-Example with maxAccel:
    {
      "lat": 37.76681832250885,
      "long": -122.4207906162038,
      "radius": 3.0,
      "maxAccel": -2.0
    }

  @apiParamExample {json} Request-Example with minTorque:
    {
      "lat": 37.76681832250885,
      "long": -122.4207906162038,
      "radius": 3.0,
      "minTorque": 20.0
    }

  @apiSuccess {Number} torque torque
  @apiSuccess {Number} velocity velocity
  @apiSuccess {Number} accel acceleration
  @apiSuccess {Number} lat Latitude
  @apiSuccess {Number} long Longitude
  @apiSuccess {String} timestamp Timestamp

  @apiSuccessExample {json} Success-Response:
    {
      "wheel_datas": [
        {
          "created_at": "2015-05-07T01:25:39.744Z",
          "id": 1,
          "torque": 1.0353324,
          "velocity": 8.3435,
          "accel": -3.32324,
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
    lat = params[:lat].to_f
    long = params[:long].to_f
    radius = params[:radius].to_i
    maxAccel = (params[:maxAccel]) ? params[:maxAccel].to_f : nil
    minTorque = (params[:minTorque]) ? params[:minTorque].to_f : nil

    # calculate distance of latitude and longitude degree
    lat_degree = MathUtility.get_lat_degree(lat, long, radius)
    long_degree = MathUtility.get_long_degree(lat, long, radius)
    is_return_json = !(lat_degree == 0 || long_degree == 0) && (maxAccel || minTorque)

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
      if maxAccel && minTorque
        where = "lat > #{lat-lat_degree} and lat < #{lat+lat_degree} and long > #{long-long_degree} and long < #{long+long_degree} and (accel < #{maxAccel} or torque > #{minTorque})"
      elsif maxAccel
        where = "lat > #{lat-lat_degree} and lat < #{lat+lat_degree} and long > #{long-long_degree} and long < #{long+long_degree} and accel < #{maxAccel}"
      elsif minTorque
        where = "lat > #{lat-lat_degree} and lat < #{lat+lat_degree} and long > #{long-long_degree} and long < #{long+long_degree} and torque > #{minTorque}"
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

end
