/// MARK: - HMAComfortParameter
class HMAComfortParameter: AnyObject {

    /// MARK: - property

    /// Fahrenheit
    var temperature: Double!
    /// Percentage
    var humidity: Double!
    /// Sound Level (dB)
    var soundLevel: Double!
    /// latitude and longitude
    var coordinate: CLLocationCoordinate2D!


    /// MARK: - property

    /**
     * get discomfort index
     * @return discomfort index
     **/
    func getDiscomfortIndex() -> Double {
        let celsius = (temperature - 32.0) / 1.8
        return 0.81 * celsius + 0.01 * humidity * (0.99 * celsius - 14.3) + 46.3
    }

}
