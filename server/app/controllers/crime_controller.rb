require './lib/assets/math_utility'


class CrimeController < ApplicationController

=begin
  @apiVersion 0.1.0

  @apiGroup Crime
  @api {get} /crime/data
  @apiName CrimeData
  @apiDescription get crime data close to your location

  @apiParam {Number} lat                        Mandatory latitude
  @apiParam {Number} long                       Mandatory longitude
  @apiParam {Number} radius                     Mandatory radius of miles to search

  @apiParamExample {json} Request-Example:
    {
      "lat": 37.76681832250885,
      "long": -122.4207906162038,
      "radius": 3.0
    }

  @apiSuccess {Number} id CrimeData ID
  @apiSuccess {String} category category of the crime. e.g. "VEHICLE THEFT"
  @apiSuccess {String} desc description of the crime. e.g. "PETTY THEFT SHOPLIFTING"
  @apiSuccess {String} resolution resolution of the crime. e.g. "ARREST, BOOKED"
  @apiSuccess {Number} lat Latitude
  @apiSuccess {Number} long Longitude
  @apiSuccess {String} timestamp Timestamp

  @apiSuccessExample {json} Success-Response:
    {
      "crime_datas": [
        {
          "created_at": "2015-05-07T01:25:39.744Z",
          "id": 1,
          "lat": 37.792097317369965,
          "long": -122.43528085596421,
          "timestamp": "2015-05-07T01:25:39.738Z",
          "updated_at": "2015-05-07T01:25:39.744Z",
          "category": "VEHICLE THEFT",
          "desc": "PETTY THEFT SHOPLIFTING",
          "resolution" : "ARREST, BOOKED"
        }
      ]
    }
=end
  def data
    # get latitude, longitude
    lat = params[:lat].to_f
    long = params[:long].to_f
    radius = params[:radius].to_f

    # calculate distance of latitude and longitude degree
    lat_degree = MathUtility.get_lat_degree(lat, long, radius)
    long_degree = MathUtility.get_long_degree(lat, long, radius)
    is_return_json = !(lat_degree == 0 || long_degree == 0)

    # response
    if is_return_json
      start_date = 3.month.ago
      end_date = 2.month.ago
      datas = CrimeData.where(
        lat: (lat-lat_degree)..(lat+lat_degree),
        long: (long-long_degree)..(long+long_degree)#,
        #timestamp: DateTime.new(start_date.year, start_date.month, 1)..DateTime.new(end_date.year, end_date.month, 1)
      )
      json = Jbuilder.encode do |j|
        j.crime_datas(datas)
      end
      render json: json
    else
      render json: { }
    end
  end


=begin
  @apiVersion 0.1.0

  @apiGroup Crime
  @api {get} /crime/type
  @apiName CrimeType
  @apiDescription get crime type

  @apiSuccess {Number} id CrimeType ID
  @apiSuccess {String} name CrimeType Name e.g. "THEFT BICYCLE"
  @apiSuccess {String} category CrimeType e.g. ""

  @apiSuccessExample {json} Success-Response:
    {
      "crime_types": [
        { "id" : 1,  "name" : "GUN",                "category" : "violence" },
        { "id" : 2,  "name" : "KNIFE",              "category" : "violence" },
        { "id" : 3,  "name" : "WEAPON",             "category" : "violence" },
        { "id" : 4,  "name" : "FIREARM",            "category" : "violence" },
        { "id" : 5,  "name" : "BATTERY",            "category" : "violence" },
        { "id" : 6,  "name" : "ASSAULT",            "category" : "violence" },
        { "id" : 7,  "name" : "RAPE",               "category" : "violence" },
        { "id" : 8,  "name" : "SHOOTING",           "category" : "violence" },
        { "id" : 9,  "name" : "THEFT BICYCLE",      "category" : "stealing_vehicle" },
        { "id" : 10, "name" : "STOLEN AUTO",        "category" : "stealing_vehicle" },
        { "id" : 11, "name" : "STOLEN MOTOR",       "category" : "stealing_vehicle" },
        { "id" : 12, "name" : "STOLEN TRUCK",       "category" : "stealing_vehicle" },
        { "id" : 13, "name" : "DRIVING",            "category" : "trafiic_violation" },
        { "id" : 14, "name" : "SPEEDING",           "category" : "trafiic_violation" },
        { "id" : 15, "name" : "TRAFFIC VIOLATION",  "category" : "trafiic_violation" },
        { "id" : 16, "name" : "ALCOHOL",            "category" : "trafiic_violation" }
      ]
    }
=end
  def type
    crime_types = CrimeType.all

    json = []
    crime_types.each do |crime_type|
      json.push(crime_type.as_json['attributes'])
    end

    render json: { :crime_types => json }
  end

end
