import CoreLocation


/// MARK: - HMAMapMath
class HMAMapMath {

    /// MARK: - class method

    /**
     * get mile from meter
     * @param meter
     * @return mile
     */
    class func mileFromMeter(meter: Double) -> Double {
        return meter / 1609.344
    }

    /**
     * get meter from mile
     * @param mile
     * @return meter
     */
    class func meterFromMile(mile: Double) -> Double {
        return mile * 1609.344
    }

    /**
     * get longitude degree from miles
     * @param radius mile
     * @param location CLLocation
     * @return degree
     */
    class func degreeOfLongitudePerRadius(radius: Double, location: CLLocation) -> Double {
        let locationLongPlus1 = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude + 1.0)
        let mile = locationLongPlus1.distanceFromLocation(location) * 0.000621371
        if mile == 0 { return 0.0 }
        return radius / mile
    }

    /**
     * get latitude degree from miles
     * @param location CLLocation
     * @param radius mile
     * @return degree
     */
    class func degreeOfLatitudePerRadius(radius: Double, location: CLLocation) -> Double {
        let locationLatPlus1 = CLLocation(latitude: location.coordinate.latitude + 1.0, longitude: location.coordinate.longitude)
        let mile = locationLatPlus1.distanceFromLocation(location) * 0.000621371
        if mile == 0 { return 0.0 }
        return radius / mile
    }

    /**
     * get distance between two locations
     * @param locationA CLLocation
     * @param locationB CLLocation
     * @return miles
     **/
    class func miles(#locationA: CLLocation, locationB: CLLocation) -> Double {
        return locationA.distanceFromLocation(locationB) * 0.000621371
    }

    /**
     * get angle between two CGPoint
     * @param pointA CGPoint
     * @param pointB CGPoint
     * @return angle Double
     **/
    class func angle(#pointA: CGPoint, pointB: CGPoint) -> Double {
        let vector = CGPointMake(pointB.x - pointA.x, pointB.y - pointA.y)
        var degree = atan2(Double(vector.y), Double(vector.x)) * (180.0 / M_PI)
        if degree < 0.0 { degree += 360.0 }
        return degree
    }
}
