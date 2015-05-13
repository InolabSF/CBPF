module MathUtility

  def self.get_lat_distance(degree)
    lat = (degree.is_a?(Float) || degree.is_a?(Fixnum)) ? 0.01448293736501 * degree : 0
    lat
  end

  def self.get_long_distance(degree, lat)
    long = 0

    return long if !(degree.is_a?(Float) || degree.is_a?(Fixnum))

    begin
      long = 1.0 / 7.03360549391553 * Math.cos(lat * 0.017453293).abs * degree
    rescue ZeroDivisionError
    end

    long
  end

end
