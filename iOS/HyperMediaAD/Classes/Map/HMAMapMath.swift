import CoreLocation


/// MARK: - HMAMapMath
class HMAMapMath {

    /// MARK: - class method

    /**
     * get mile from longitude and degree
     * @param latitude latitude
     * @param degree degree of longitude
     * @return mile
     */
    class func mileOfLongitude(#latitude: Double, degree: Double) -> Double {
        let locationA = CLLocation(latitude: Double(latitude), longitude: Double(0.0))
        let locationB = CLLocation(latitude: Double(latitude), longitude: Double(degree))
        return locationB.distanceFromLocation(locationA) * 0.000621371
/*
        let temp = 7.03360549391553 * abs(cos(latitude * 0.017453293)) * degree
        if temp == 0 { return 0.0 }
        return 1.0 / temp
*/
    }

    /**
     * get mile from latitude and degree
     * @param degree degree of longitude
     * @return mile
     */
    class func mileOfLatitude(#degree: Double) -> Double {
        let locationA = CLLocation(latitude: Double(0.0), longitude: Double(0.0))
        let locationB = CLLocation(latitude: Double(degree), longitude: Double(0.0))
        return locationB.distanceFromLocation(locationA) * 0.000621371
/*
        //return 60.0 * degree
        //return abs(cos(degree * 0.017453293)) * 111.3194908
        //return 0.01448293736501 * degree
*/
    }

}
