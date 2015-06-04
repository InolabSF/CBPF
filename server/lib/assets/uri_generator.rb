require 'uri'


module UriGenerator

  # aircasting average API
  def self.aircasting_average(sensor_name, measurement_type, unit_symbol, date_from, date_to)
    query = {}

    # San Francisco rectangle
    query['q[west]'] = -122.52
    query['q[east]'] = -122.35
    query['q[north]'] = 37.815
    query['q[south]'] = 37.7
    # grid size
    query['q[grid_size_x]'] = 68.59464627151051
    query['q[grid_size_y]'] = 25
    # time
    query['q[time_from]'] = 420
    query['q[time_to]'] = 419
    # day of year
    query['q[day_from]'] = date_from.yday
    query['q[day_to]'] = date_to.yday
    # year
    query['q[year_from]'] = date_from.year
    query['q[year_to]'] = date_to.year
    # sensor
    query['q[sensor_name]'] = sensor_name
    query['q[measurement_type]'] = measurement_type
    query['q[unit_symbol]'] = unit_symbol

    uri = URI("http://aircasting.org/api/averages")
    uri.query = query.to_param

    uri
  end

  # San Francisco Government Crime API
  def self.sf_government_crime(how_many_month_ago, period_of_month)
    query = {}
    query['$where'] = 'date > \'' + how_many_month_ago.months.ago.strftime('%Y-%m-01T00:00:00') + '\' and date < \'' + (how_many_month_ago - period_of_month).months.ago.strftime('%Y-%m-01T00:00:00') + '\''
    uri = URI('http://data.sfgov.org/api/resource/tmnf-yvry.json')
    uri.query = query.to_param

    uri
  end

end
