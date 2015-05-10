import Foundation


/// MARK: - HMASale
class HMASensorClient: AnyObject {

    /// MARK: - property

    /// MARK: - class method
    /**
     * GET /sensor/data
     * @param sensorType sensorType
     * @param coordinate latitude and longitude
     * @param completionHandler (json: JSON) -> Void
     */
    class func getSensorData(#sensorType: Int, coordinate: CLLocationCoordinate2D, completionHandler: (json: JSON) -> Void) {
        // check if there is an event that matches user profile
        let URLString = kURISensorData + "?sensorType=\(sensorType)&lat=\(coordinate.latitude)&long=\(coordinate.longitude)"
        let request = NSMutableURLRequest(URL: NSURL(string: URLString)!)
        ISHTTPOperation.sendRequest(request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                let responseJSON = JSON(data: object as! NSData)
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
    }

}
