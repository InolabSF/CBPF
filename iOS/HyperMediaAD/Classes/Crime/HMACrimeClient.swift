import Foundation


/// MARK: - HMACrimeClient
class HMACrimeClient: AnyObject {

    /// MARK: - property

    var crimeTypes: JSON? = nil


    /// MARK: - class method

    static let sharedInstance = HMACrimeClient()


    /// MARK: - public api

//    /**
//     * GET /crime/type
//     * @param completionHandler () -> Void
//     */
//    func getCrimeType(
//        #completionHandler: () -> Void
//    ) {
//        let request = NSMutableURLRequest(URL: NSURL(string: HMACrime.API.Type)!)
//
//        // request
//        var operation = ISHTTPOperation(
//            request: request,
//            handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
//                if error != nil { return }
//
//                var responseJSON: JSON? = nil
//                if object != nil { responseJSON = JSON(data: object as! NSData) }
//                else { return }
//
//                dispatch_async(dispatch_get_main_queue(), {
//                    if responseJSON != nil && HMACrimeClient.sharedInstance.crimeTypes == nil {
//                        HMACrimeClient.sharedInstance.crimeTypes = responseJSON
//                        completionHandler()
//                    }
//                })
//            }
//        )
//        HMACrimeOperationQueue.sharedInstance.addOperation(operation)
//    }
//
//    /**
//     * cancel get crime type API
//     **/
//    func cancelGetCrimeType() {
//        HMACrimeOperationQueue.sharedInstance.cancelOperationsWithPath(NSURL(string: HMACrime.API.Type)!.path)
//    }

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
                if error != nil { return }

                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                else { return }

                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMACrimeOperationQueue.sharedInstance.addOperation(operation)
    }

    /**
     * cancel get crime API
     **/
    func cancelGetCrime() {
        HMACrimeOperationQueue.sharedInstance.cancelOperationsWithPath(NSURL(string: HMACrime.API.Data)!.path)
    }

}
