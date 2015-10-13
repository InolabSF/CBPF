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
        origin origin: CLLocationCoordinate2D,
        destinations: [CLLocationCoordinate2D],
        waypoints: [CLLocationCoordinate2D],
        completionHandler: (jsons: [JSON]) -> Void
    ) {
        MTStatusBarOverlay.sharedInstance().postMessage("Searching Route")

        self.routeJSONs = []

        // pick the closest waypoints for the route
        var waypointsForTheRoute: [[CLLocationCoordinate2D]] = []
        for var i = 0; i < destinations.count; i++ { waypointsForTheRoute.append([]) }
        var a, b: CLLocationCoordinate2D
        a = origin
        for var i = 0; i < waypoints.count; i++ {
            var theShortestIndex = 0
            var theShortestDistance = Double(HMAAPI.Radius)
            for var j = 0; j < destinations.count; j++ {
                b = destinations[j]
                let distance = (HMAMapMath.miles(locationA: CLLocation(latitude: a.latitude, longitude: a.longitude), locationB: CLLocation(latitude: waypoints[i].latitude, longitude: waypoints[i].longitude)) + HMAMapMath.miles(locationA: CLLocation(latitude: b.latitude, longitude: b.longitude), locationB: CLLocation(latitude: waypoints[i].latitude, longitude: waypoints[i].longitude))) / 2.0
                if distance < theShortestDistance {
                    theShortestDistance = distance
                    theShortestIndex = j
                }
                a = b
            }
            waypointsForTheRoute[theShortestIndex].append(waypoints[i])
        }

        // google map direction API
        a = origin
        for var i = 0; i < destinations.count; i++ {
            let isLast = (i == destinations.count - 1)
            b = destinations[i]

            // making queries
            var queries = [ "origin" : "\(a.latitude),\(a.longitude)", "destination" : "\(b.latitude),\(b.longitude)", ]
            if waypointsForTheRoute[i].count > 0 {
                queries["waypoints"] = "optimize:true|"
                for var j = 0; j < waypointsForTheRoute[i].count; j++ {
                    let coordinate = waypointsForTheRoute[i][j]
                    queries["waypoints"] = queries["waypoints"]! + "\(coordinate.latitude),\(coordinate.longitude)|"
                }
            }
            // API
            self.getRoute(
                queries: queries,
                completionHandler: { [unowned self] (json) in
                    self.routeJSONs.append(json)
                    if isLast {
                        completionHandler(jsons: self.routeJSONs)
                        MTStatusBarOverlay.sharedInstance().hide()
                    }
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
    func getRoute(queries queries: Dictionary<String, AnyObject>, completionHandler: (json: JSON) -> Void) {
        // make request
        var q: Dictionary<String, AnyObject> = [
            HMAGoogleMap.TravelMode: HMAGoogleMap.TravelModes.Bicycling,
            "sensor": "false",
        ]
        for (key, value) in queries { q[key] = value }
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMAGoogleMap.API.Directions, queries: q)!)

        // request
        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMAGoogleMapOperationQueue.sharedInstance.addOperation(operation)
    }

    /**
     * cancel direction API
     **/
    func cancelGetRoute() {
        HMAGoogleMapOperationQueue.sharedInstance.cancelOperationsWithPath(NSURL(string: HMAGoogleMap.API.Directions)!.path)
    }

    /**
     * request google map geocode API (https://developers.google.com/maps/documentation/geocoding/)
     * @param address address
     * @param radius mile
     * @param location location
     * @param completionHandler (json: JSON) -> Void
     */
    func getGeocode(address address: String, radius: Double, location: CLLocationCoordinate2D, completionHandler: (json: JSON) -> Void) {
        // make request
        let offsetLong = HMAMapMath.degreeOfLongitudePerRadius(radius, location: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let offsetLat = HMAMapMath.degreeOfLatitudePerRadius(radius, location: CLLocation(latitude: location.latitude, longitude: location.longitude))
        let queries = [
            "address" : address,
            "bounds" : "\(location.latitude-offsetLat),\(location.longitude-offsetLong)|\(location.latitude+offsetLat),\(location.longitude+offsetLong)", // latitude,longitude
        ]
        let request = NSMutableURLRequest(URL: NSURL(URLString: HMAGoogleMap.API.GeoCode, queries: queries)!)

        // request
        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMAGoogleMapOperationQueue.sharedInstance.addOperation(operation)
    }

    /**
     * cancel geocode API
     **/
    func cancelGetGeocode() {
        HMAGoogleMapOperationQueue.sharedInstance.cancelOperationsWithPath(NSURL(string: HMAGoogleMap.API.GeoCode)!.path)
    }

    /**
     * request google map API (https://developers.google.com/places/webservice/autocomplete)
     * @param input search words
     * @param radius mile
     * @param location location
     * @param completionHandler (json: JSON) -> Void
     */
    func getPlaceAutoComplete(input input: String, radius: Double, location: CLLocationCoordinate2D, completionHandler: (json: JSON) -> Void) {
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
        let operation = ISHTTPOperation(request: request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                else {
                    MTStatusBarOverlay.sharedInstance().postImmediateErrorMessage("Failed", duration:2.0, animated:true)
                    return
                }

                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
        HMAGoogleMapOperationQueue.sharedInstance.addOperation(operation)
    }

    /**
     * cancel get place auto complete API
     **/
    func cancelGetPlaceAutoComplete() {
        HMAGoogleMapOperationQueue.sharedInstance.cancelOperationsWithPath(NSURL(string: HMAGoogleMap.API.PlaceAutoComplete)!.path)
    }

}
