require 'uri'
require './lib/assets/http_client'
require './lib/assets/uri_generator'


class Tasks::CrimeDataCollectionTask
  def self.execute
    # uri
    uri = UriGenerator.sf_government_crime

    # request header
    request_header = {}
    request_header['Accept'] = 'application/json'

    json = HttpClient.get_json(uri.to_s, request_header, true)
    puts json
=begin
    json example
    [
      {
        "time" : "08:42",
        "category" : "LARCENY/THEFT",
        "pddistrict" : "SOUTHERN",
        "pdid" : "13054930206362",
        "location" : {
          "needs_recoding" : false,
          "longitude" : "-122.407633520742",
          "latitude" : "37.7841893501425",
          "human_address" : "{\"address\":\"\",\"city\":\"\",\"state\":\"\",\"zip\":\"\"}"
        },
        "address" : "800 Block of MARKET ST",
        "descript" : "PETTY THEFT SHOPLIFTING",
        "dayofweek" : "Tuesday",
        "resolution" : "ARREST, BOOKED",
        "date" : "2015-02-03T00:00:00",
        "y" : "37.7841893501425",
        "x" : "-122.407633520742",
        "incidntnum" : "130549302"
      },
      ...
    ]
=end
=begin
    # create crime_data
    json.each do |crime_json|
      crime_data = CrimeData.new

      crime_data.desc = crime_json['descript']
      crime_data.resolution = crime_json['resolution']
      location_json = crime_json['location']
      if location_json
        crime_data.lat = location_json['latitude']
        crime_data.long = location_json['longitude']
      end
      crime_data.timestamp = DateTime.strptime(crime_json['date'] + crime_json['time'], '%Y-%m-%dT00:00:00%H:%M')

      crime_data.save if crime_data.valid?
    end
=end
  end
end
