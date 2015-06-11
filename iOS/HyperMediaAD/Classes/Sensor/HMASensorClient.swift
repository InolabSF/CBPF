import Foundation


/// MARK: - HMASensorClient
class HMASensorClient: AnyObject {

    /// MARK: - class method

    static let sharedInstance = HMASensorClient()


    /// MARK: - public api

    /**
     * GET /sensor/data
     * @param radius radius of miles to search
     * @param sensorType sensorType
     * @param coordinate latitude and longitude
     * @param completionHandler (json: JSON) -> Void
     */
    func getSensorData(#radius: Double, sensorType: Int, coordinate: CLLocationCoordinate2D, completionHandler: (json: JSON) -> Void) {
        // make request
        var queries: Dictionary<String, AnyObject> = [
            "sensor_type": "\(sensorType)",
            "lat": "\(coordinate.latitude)",
            "long": "\(coordinate.longitude)",
            "radius": "\(radius)",
        ]
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMASensor.API.Data, queries: queries)!)

        // request
        var operation = ISHTTPOperation(
            request: request,
            handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMASensorOperationQueue.defaultQueue().addOperation(operation)
    }

    /**
     * cancel GET sensor/data
     **/
    func cancelGetSensorData() {
        HMASensorOperationQueue.defaultQueue().cancelOperationsWithPath(NSURL(string: HMASensor.API.Data)!.path)
    }

}
