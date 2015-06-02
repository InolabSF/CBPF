import Foundation


/// MARK: - HMACrimeClient
class HMACrimeClient: AnyObject {

    /// MARK: - property

    /// MARK: - class method

    static let sharedInstance = HMACrimeClient()


    /// MARK: - public api

    /**
     * GET /crime/data
     * @param radius radius of miles to search
     * @param coordinate latitude and longitude
     * @param completionHandler (json: JSON) -> Void
     */
    func getCrime(
        #radius: Float,
        coordinate: CLLocationCoordinate2D,
        completionHandler: (json: JSON) -> Void
    ) {
        // make request
        var queries: Dictionary<String, AnyObject> = [
            "radius": "\(radius)",
            "lat": "\(coordinate.latitude)",
            "long": "\(coordinate.longitude)",
        ]
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMACrime.API.Data, queries: queries)!)

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
        HMACrimeOperationQueue.defaultQueue().addOperation(operation)
    }

    /**
     * cancel get crime API
     **/
    func cancelGetCrime() {
        HMACrimeOperationQueue.defaultQueue().cancelOperationsWithPath(NSURL(string: HMACrime.API.Data)!.path)
    }

}
