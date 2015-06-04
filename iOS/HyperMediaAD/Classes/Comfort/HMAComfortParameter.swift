/// MARK: - HMAComfortParameter
class HMAComfortParameter: AnyObject {

    /// MARK: - property

    /// Fahrenheit
    var temperature: Double!
    /// Percentage
    var humidity: Double!
    /// µg/m³
    var pm25: Double!
    /// Sound Level (dB)
    var soundLevel: Double!
    /// latitude and longitude
    var coordinate: CLLocationCoordinate2D!


    /// MARK: - property

    /**
     * get heat index
     * @return heat index
     **/
    func getHeatIndex() -> Double {
        let celsius = (temperature - 32.0) / 1.8
        return 0.81 * celsius + 0.01 * humidity * (0.99 * celsius - 14.3) + 46.3
    }

}
