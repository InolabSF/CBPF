=begin
  @apiVersion 1.0.0

  @apiGroup Devices
  @api {get} /devices/all.geojson
  @apiName DevicesAll
  @apiDescription get all sensor data

  @apiSuccessExample {json} Success-Response:
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
          "type": "Point",
          "coordinates": [
            "2.289387000000033",
            "48.804689000000000"
          ]
          },
          "properties": {
            "id": "705",
            "user_id": "742",
            "kit_version": "1.1",
            "title": "Chatillon",
            "location": "Châtillon, France",
            "exposure": "indoor",
            "position": "fixed",
            "elevation": "150.0",
            "created": "2014-02-17 19:36:38",
            "modified": "2015-04-03 17:23:03",
            "last_insert_datetime": "2015-04-30 03:28:54",
            "status": "online",
            "debug_push": 0,
            "debug_mode": "Disabled",
            "feeds": [
              {
              "id": "47257431",
              "timestamp": "2015-04-30 03:28:52",
              "temp": 16.7,
              "hum": 49,
              "co": 41.1,
              "no2": 93.1,
              "light": 0,
              "noise": 50,
              "bat": 100,
              "panel": 0,
              "nets": 7,
              "geo_lat": null,
              "geo_long": null
              }
            ]
          }
        }
      ]
    }
=end

=begin
  @apiVersion 1.0.0

  @apiGroup Stats
  @api {get} /stats/basic.json
  @apiName StatsBasic
  @apiDescription get statistics of all sensor data

  @apiSuccessExample {json} Success-Response:
    {
      "stats": {
        "total_devices": 1067,
        "total_sensors": 5335,
        "total_datapoints": 47257539
      }
    }
=end
