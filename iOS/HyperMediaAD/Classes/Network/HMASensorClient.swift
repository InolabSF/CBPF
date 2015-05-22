import Foundation


/// MARK: - HMASensorClient
class HMASensorClient: AnyObject {

    /// MARK: - class method

    static let sharedInstance = HMASensorClient()


    /// MARK: - public api

    /**
     * GET /sensor/data
     * @param sensorType sensorType
     * @param coordinate latitude and longitude
     * @param completionHandler (json: JSON) -> Void
     */
    func getSensorData(#sensorType: Int, coordinate: CLLocationCoordinate2D, completionHandler: (json: JSON) -> Void) {
        // make request
        var queries: Dictionary<String, AnyObject> = [
            "sensorType": "\(sensorType)",
            "lat": "\(coordinate.latitude)",
            "long": "\(coordinate.longitude)",
        ]
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMASensor.API.Data, queries: queries)!)

        // request
        ISHTTPOperation.sendRequest(request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
    }

}
