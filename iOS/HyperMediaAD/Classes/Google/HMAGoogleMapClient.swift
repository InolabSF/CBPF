import Foundation


/// MARK: - HMAGoogleMapClient
class HMAGoogleMapClient: AnyObject {

    /// MARK: - property

    private var routeJSONs: [JSON] = []


    /// MARK: - class method

    static let sharedInstance = HMAGoogleMapClient()


    /// MARK: - public api

    /**
     * get routes
     * @param origin CLLocationCoordinate2D
     * @param destinations [CLLocationCoordinate2D]
     * @param waypoints [CLLocationCoordinate2D]
     * @param completionHandler (jsons: [JSON]) -> Void
     **/
    func getRoutes(
        #origin: CLLocationCoordinate2D,
        destinations: [CLLocationCoordinate2D],
        waypoints: [CLLocationCoordinate2D],
        completionHandler: (jsons: [JSON]) -> Void
    ) {
        self.routeJSONs = []

        // google map direction API
        var a = origin
        for var i = 0; i < destinations.count; i++ {
            var isLast = (i == destinations.count - 1)
            var b = destinations[i]
            self.getRoute(
                queries: [ "origin" : "\(a.latitude),\(a.longitude)", "destination" : "\(b.latitude),\(b.longitude)", ],
                completionHandler: { (json) in
                    HMAGoogleMapClient.sharedInstance.routeJSONs.append(json)
                    if isLast { completionHandler(jsons: HMAGoogleMapClient.sharedInstance.routeJSONs) }
                }
            )
            a = b
        }
    }

    /**
     * request google map directions API (https://developers.google.com/maps/documentation/directions/)
     * @param queries URI queries
     *  e.g. 1
     *  {
     *      "origin" : "-122.4207906162038,37.76681832250885", // longitude,latitude
     *      "destination" : "-122.3131,37.5542",
     *  }
     *  e.g. 2
     *  {
     *      "origin" : "San Francisco",
     *      "destination" : "Los Angeles",
     *      "waypoints" : "optimize:true|-122.40,37.65|-122.34,37.59|", //"waypoints" : "optimize:true|San Francisco Airport|Dalycity|",
     *      "alternatives" : "true",
     *      "avoid" : "highways",
     *      "units" : "metric",
     *      "region" : ".us",
     *      "departure_time" : "1343605500",
     *      "arrival_time" : "1343605500",
     *      "mode": "bicycling", // driving, walking, bicycling
     *      "sensor": "false",
     *  }
     * @param completionHandler (json: JSON) -> Void
     */
    func getRoute(#queries: Dictionary<String, AnyObject>, completionHandler: (json: JSON) -> Void) {
        // make request
        var q: Dictionary<String, AnyObject> = [
            HMAGoogleMap.TravelMode: HMAGoogleMap.TravelModes.Bicycling,
            "sensor": "false",
        ]
        // waypoints
        let waypoints = HMAMapView.sharedInstance.waypoints
        if waypoints.count > 0 {
            q["waypoints"] = "optimize:true|"
            for var i = 0; i < waypoints.count; i++ {
                let coordinate = waypoints[i]
                q["waypoints"] = (q["waypoints"] as! String) + "\(coordinate.latitude),\(coordinate.longitude)|"
            }
        }
        for (key, value) in queries { q[key] = value }
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMAGoogleMap.API.Directions, queries: q)!)

        // request
        var operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMAGoogleMapOperationQueue.defaultQueue().addOperation(operation)
    }

    /**
     * cancel direction API
     **/
    func cancelGetRoute() {
        HMAGoogleMapOperationQueue.defaultQueue().cancelOperationsWithPath(NSURL(string: HMAGoogleMap.API.Directions)!.path)
    }

    /**
     * request google map geocode API (https://developers.google.com/maps/documentation/geocoding/)
     * @param address address
     * @param radius mile
     * @param location location
     * @param completionHandler (json: JSON) -> Void
     */
    func getGeocode(#address: String, radius: Double, location: CLLocationCoordinate2D, completionHandler: (json: JSON) -> Void) {
        // make request
        let offsetLong = HMAMapMath.degreeOfLongitudePerRadius(radius, location: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let offsetLat = HMAMapMath.degreeOfLatitudePerRadius(radius, location: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let queries = [
            "address" : address,
            "bounds" : "\(location.latitude-offsetLat),\(location.longitude-offsetLong)|\(location.latitude+offsetLat),\(location.longitude+offsetLong)", // latitude,longitude
        ]
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMAGoogleMap.API.GeoCode, queries: queries)!)

        // request
        var operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMAGoogleMapOperationQueue.defaultQueue().addOperation(operation)
    }

    /**
     * cancel geocode API
     **/
    func cancelGetGeocode() {
        HMAGoogleMapOperationQueue.defaultQueue().cancelOperationsWithPath(NSURL(string: HMAGoogleMap.API.GeoCode)!.path)
    }

    /**
     * request google map API (https://developers.google.com/places/webservice/autocomplete)
     * @param input search words
     * @param radius mile
     * @param location location
     * @param completionHandler (json: JSON) -> Void
     */
    func getPlaceAutoComplete(#input: String, radius: Double, location: CLLocationCoordinate2D, completionHandler: (json: JSON) -> Void) {
        // make request
        let queries = [
            "input" : input,
            "radius" : "\(HMAMapMath.meterFromMile(radius))",
            "location" : "\(location.latitude),\(location.longitude)", // latitude,longitude
            "sensor" : "false",
            "key" : HMAGoogleMap.BrowserAPIKey,
        ]
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMAGoogleMap.API.PlaceAutoComplete, queries: queries)!)

        // request
        var operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMAGoogleMapOperationQueue.defaultQueue().addOperation(operation)
    }

    /**
     * cancel get place auto complete API
     **/
    func cancelGetPlaceAutoComplete() {
        HMAGoogleMapOperationQueue.defaultQueue().cancelOperationsWithPath(NSURL(string: HMAGoogleMap.API.PlaceAutoComplete)!.path)
    }

}
