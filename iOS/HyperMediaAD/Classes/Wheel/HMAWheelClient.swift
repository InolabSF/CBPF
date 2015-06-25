import Foundation


/// MARK: - HMAWheelClient
class HMAWheelClient: AnyObject {

    /// MARK: - property

    /// MARK: - class method

    static let sharedInstance = HMAWheelClient()


    /// MARK: - public api

    /**
     * GET /wheel/data
     * @param radius radius of miles to search
     * @param dataType dataType
     * @param max maxValue
     * @param min minValue
     * @param coordinate latitude and longitude
     * @param completionHandler (json: JSON) -> Void
     */
    func getWheelData(#radius: Float, dataType: Int, max: Float?, min: Float?, coordinate: CLLocationCoordinate2D, completionHandler: (json: JSON) -> Void) {
        // make request
        var queries: Dictionary<String, AnyObject> = [
            "data_type": "\(dataType)",
            "lat": "\(coordinate.latitude)",
            "long": "\(coordinate.longitude)",
            "radius": "\(radius)",
        ]
        if max != nil { queries["max"] = "\(max!)" }
        if min != nil { queries["min"] = "\(min!)" }
        self.getWheelData(queries: queries, completionHandler: completionHandler)
    }

    /**
     * cancel GET wheel/data
     * @param dataType dataType
     **/
    func cancelGetWheelData(#dataType: Int) {
        let predicate = NSPredicate(format: "request.URL.absoluteString CONTAINS[c] %@", "data_type=\(dataType)")
        HMAWheelOperationQueue.defaultQueue().cancelOperationsUsingPredicate(predicate)
    }


    /// MARK: - private api

    /**
     * GET /wheel/data
     * @param radius radius of miles to search
     * @param dataType dataType
     * @param max maxValue
     * @param min minValue
     * @param coordinate latitude and longitude
     * @param completionHandler (json: JSON) -> Void
     */
    func getWheelData(#queries: Dictionary<String, AnyObject>, completionHandler: (json: JSON) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMAWheel.API.Data, queries: queries)!)

        // request
        var operation = ISHTTPOperation(
            request: request,
            handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                if error != nil { return }

                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                else { return }

                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMAWheelOperationQueue.defaultQueue().addOperation(operation)
    }

}
