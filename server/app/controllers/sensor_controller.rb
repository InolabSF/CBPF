class SensorController < ApplicationController

  # GET /sensor/data
  def data
    # get latitude, longitude
    lat = params[:lat].to_f
    long = params[:long].to_f
    is_return_json = false unless lat.is_a?(Float) && long.is_a?(Float)

    # calculate degree of 3 mile
    lat_3_mile = 0.01448293736501 * 3.0
    long_3_mile = 0
    if is_return_json
      begin
        long_3_mile = 1.0 / 7.03360549391553 * Math.cos(lat * 0.017453293).abs * 3.0
      rescue ZeroDivisionError
        format.html
        is_return_json = false
      end
    end

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
