class CrimeController < ApplicationController

=begin
  @apiVersion 0.1.0

  @apiGroup Crime
  @api {get} /crime/data
  @apiName CrimeData
  @apiDescription get crime data close to your location

  @apiParam {Number} lat                        Mandatory latitude
  @apiParam {Number} long                       Mandatory longitude

  @apiParamExample {json} Request-Example:
    {
      "lat": 37.76681832250885,
      "long": -122.4207906162038
    }

  @apiSuccess {Number} id CrimeData ID
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

    # calculate distance of latitude and longitude degree
    degree = 3.0
    lat_3_mile = MathUtility.get_lat_distance(degree)
    long_3_mile = MathUtility.get_long_distance(degree, lat)
    is_return_json = !(lat_3_mile == 0 || long_3_mile == 0)

    # response
    if is_return_json
      datas = CrimeData.where(lat: (lat-lat_3_mile)..(lat+lat_3_mile), long: (long-long_3_mile)..(long+long_3_mile))
      json = Jbuilder.encode do |j|
        j.crime_datas(datas)
      end
      render json: json
    else
      render json: { }
    end
  end

end
