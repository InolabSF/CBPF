=begin
  @apiVersion 1.0.0

  @apiGroup Average
  @api {get} /api/average
  @apiName average
  @apiDescription get sensor data

  @apiParam {Number} q_west                 Mandatory
  @apiParam {Number} q_east                 Mandatory
  @apiParam {Number} q_north                Mandatory
  @apiParam {Number} q_south                Mandatory
  @apiParam {Number} q_grid_size_x          Mandatory
  @apiParam {Number} q_grid_size_y          Mandatory
  @apiParam {Number} q_time_from            Mandatory
  @apiParam {Number} q_time_to              Mandatory
  @apiParam {Number} q_year_from            Mandatory
  @apiParam {Number} q_year_to              Mandatory
  @apiParam {String} q_tags                 Optional
  @apiParam {String} q_usernames            Optional
  @apiParam {String} q_measurement_type     Mandatory
  @apiParam {String} q_sensor_name          Mandatory
  @apiParam {String} q_unit_symbol          Mandatory

  @apiParamExample {json} Humidity Example
    {
      "q[west]": -122.61790245771408,
      "q[east]": -122.12523430585861,
      "q[north]": 37.81255380021123,
      "q[south]": 37.67056320509009,
      "q[grid_size_x]": 68.59464627151051,
      "q[grid_size_y]": 25,
      "q[time_from]": 420,
      "q[time_to]": 419,
      "q[day_from]": 0,
      "q[day_to]": 365,
      "q[year_from]": 2011,
      "q[year_to]": 2015,
      "q[tags]": "",
      "q[usernames]": "",
      "q[measurement_type]": "Relative Humidity",
      "q[sensor_name]": "AirBeam-RH",
      "q[unit_symbol]": "%"
    }

  @apiParamExample {json} CO Example
    {
      "q[west]": -122.61790245771408,
      "q[east]": -122.12523430585861,
      "q[north]": 37.81255380021123,
      "q[south]": 37.67056320509009,
      "q[grid_size_x]": 68.59464627151051,
      "q[grid_size_y]": 25,
      "q[time_from]": 420,
      "q[time_to]": 419,
      "q[day_from]": 0,
      "q[day_to]": 365,
      "q[year_from]": 2011,
      "q[year_to]": 2015,
      "q[tags]": "",
      "q[usernames]": "",
      "q[measurement_type]": "CO Gas",
      "q[sensor_name]": "CO-B4",
      "q[unit_symbol]": "bits"
    }

  @apiParamExample {json} CO2 Example
    {
      "q[west]": -122.61790245771408,
      "q[east]": -122.12523430585861,
      "q[north]": 37.81255380021123,
      "q[south]": 37.67056320509009,
      "q[grid_size_x]": 68.59464627151051,
      "q[grid_size_y]": 25,
      "q[time_from]": 420,
      "q[time_to]": 419,
      "q[day_from]": 0,
      "q[day_to]": 365,
      "q[year_from]": 2011,
      "q[year_to]": 2015,
      "q[tags]": "",
      "q[usernames]": "",
      "q[measurement_type]": "CO2 Gas",
      "q[sensor_name]": "MQ-135",
      "q[unit_symbol]": "RI"
    }

  @apiParamExample {json} NO2 Example
    {
      "q[west]": -122.61790245771408,
      "q[east]": -122.12523430585861,
      "q[north]": 37.81255380021123,
      "q[south]": 37.67056320509009,
      "q[grid_size_x]": 68.59464627151051,
      "q[grid_size_y]": 25,
      "q[time_from]": 420,
      "q[time_to]": 419,
      "q[day_from]": 0,
      "q[day_to]": 365,
      "q[year_from]": 2011,
      "q[year_to]": 2015,
      "q[tags]": "",
      "q[usernames]": "",
      "q[measurement_type]": "N02 Gas",
      "q[sensor_name]": "MiCS-2710",
      "q[unit_symbol]": "ppm"
    }

  @apiParamExample {json} PM2.5 Example
    {
      "q[west]": -122.61790245771408,
      "q[east]": -122.12523430585861,
      "q[north]": 37.81255380021123,
      "q[south]": 37.67056320509009,
      "q[grid_size_x]": 68.59464627151051,
      "q[grid_size_y]": 25,
      "q[time_from]": 420,
      "q[time_to]": 419,
      "q[day_from]": 0,
      "q[day_to]": 365,
      "q[year_from]": 2011,
      "q[year_to]": 2015,
      "q[tags]": "",
      "q[usernames]": "",
      "q[measurement_type]": "PM2.5",
      "q[sensor_name]": "PDR-1500",
      "q[unit_symbol]": "ug/m3"
    }

  @apiParamExample {json} Sound Level Example
    {
      "q[west]": -122.61790245771408,
      "q[east]": -122.12523430585861,
      "q[north]": 37.81255380021123,
      "q[south]": 37.67056320509009,
      "q[grid_size_x]": 68.59464627151051,
      "q[grid_size_y]": 25,
      "q[time_from]": 420,
      "q[time_to]": 419,
      "q[day_from]": 0,
      "q[day_to]": 365,
      "q[year_from]": 2011,
      "q[year_to]": 2015,
      "q[tags]": "",
      "q[usernames]": "",
      "q[measurement_type]": "Sound Level",
      "q[sensor_name]": "2Phone Microphone",
      "q[unit_symbol]": "dB"
    }

  @apiParamExample {json} Temperature Example
    {
      "q[west]": -122.61790245771408,
      "q[east]": -122.12523430585861,
      "q[north]": 37.81255380021123,
      "q[south]": 37.67056320509009,
      "q[grid_size_x]": 68.59464627151051,
      "q[grid_size_y]": 25,
      "q[time_from]": 420,
      "q[time_to]": 419,
      "q[day_from]": 0,
      "q[day_to]": 365,
      "q[year_from]": 2011,
      "q[year_to]": 2015,
      "q[tags]": "",
      "q[usernames]": "",
      "q[measurement_type]": "Temperature",
      "q[sensor_name]": "AirBeam-F",
      "q[unit_symbol]": "F"
    }

  @apiParamExample {json} Light Example
    {
      "q[west]": -122.61790245771408,
      "q[east]": -122.12523430585861,
      "q[north]": 37.81255380021123,
      "q[south]": 37.67056320509009,
      "q[grid_size_x]": 68.59464627151051,
      "q[grid_size_y]": 25,
      "q[time_from]": 420,
      "q[time_to]": 419,
      "q[day_from]": 0,
      "q[day_to]": 365,
      "q[year_from]": 2011,
      "q[year_to]": 2015,
      "q[tags]": "",
      "q[usernames]": "",
      "q[measurement_type]": "Light",
      "q[sensor_name]": "OwlPouch",
      "q[unit_symbol]": "RI"
    }

  @apiSuccess {Number} value SensorData value
  @apiSuccess {Number} west The westest longitude
  @apiSuccess {Number} east The eastest longitude
  @apiSuccess {Number} south The southest latitude
  @apiSuccess {String} north The northest latitude

  @apiSuccessExample {json} Success-Response:
    [
      {
        "value": 6,
        "west": -122.15634374057545,
        "east": -122.14909862069523,
        "south": 37.70046096099841,
        "north": 37.7067807097137
      }
    ]
=end

