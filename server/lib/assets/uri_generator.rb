require 'uri'


module UriGenerator

  # aircasting average API
  def self.aircasting_average(sensor_name, measurement_type, unit_symbol)
    query = {}

    query['q[west]'] = -122.61790245771408
    query['q[east]'] = -122.12523430585861
    query['q[north]'] = 37.81255380021123
    query['q[south]'] = 37.67056320509009
    query['q[grid_size_x]'] = 68.59464627151051
    query['q[grid_size_y]'] = 25
    query['q[time_from]'] = 420
    query['q[time_to]'] = 419
    query['q[day_from]'] = 0
    query['q[day_to]'] = 365
    query['q[year_from]'] = 2011
    query['q[year_to]'] = 2015

    query['q[sensor_name]'] = sensor_name
    query['q[measurement_type]'] = measurement_type
    query['q[unit_symbol]'] = unit_symbol

    uri = URI("http://aircasting.org/api/averages")
    uri.query = query.to_param

    uri
  end

  # sf government crime API
  def self.sf_government_crime
    query = {}
    query['$where'] = 'date > \'' + 3.months.ago.strftime('%Y-%m-01T00:00:00') + '\' and date < \'' + 2.months.ago.strftime('%Y-%m-01T00:00:00') + '\''
    uri = URI('http://data.sfgov.org/api/resource/tmnf-yvry.json')
    uri.query = query.to_param

    uri
  end

end
