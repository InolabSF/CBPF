/// MARK: - HMAMapView
class HMAMapView: GMSMapView {

    /// MARK: - properties

    static let sharedInstance = HMAMapView()

    /// dragging waypoint
    private var draggingWaypoint: CLLocationCoordinate2D!
    /// waypoints for routing
    var waypoints: [CLLocationCoordinate2D] = []
    /// route json
    private var routeJSON: JSON?
    /// crimes
    private var crimes: [HMACrimeData]?


    /// MARK: - public api

    /**
     * draw all markers, route, overlays and something like that
     **/
    func draw() {
        self.clear()
        if self.crimes != nil { self.drawCrimes() }
        if self.routeJSON != nil { self.drawRoute() }
    }

    /**
     * set route json
     * @param json json
     **/
    func setRouteJSON(json: JSON?) {
        self.routeJSON = json
        if json == nil { self.removeAllWaypoints() }
    }

    /**
     * set crimes
     * @param crimes [HMACrime]
     **/
    func setCrimes(crimes: [HMACrimeData]?) {
        self.crimes = crimes
    }

    /**
     * add waypoint for routing
     * @param waypoint waypoint
     */
    func appendWaypoint(waypoint: CLLocationCoordinate2D) {
        self.waypoints.append(waypoint)
    }

    /**
     * remove all waypoints for routing
     */
    func removeAllWaypoints() {
        self.waypoints = []
    }

    /**
     * startMovingWaypoint
     * @param waypoint waypoint
     */
    func startMovingWaypoint(waypoint: CLLocationCoordinate2D) {
        self.draggingWaypoint = waypoint
    }

    /**
     * endMovingWaypoint
     * @param waypoint waypoint
     */
    func endMovingWaypoint(waypoint: CLLocationCoordinate2D) {
        var index = -1
        for var i = 0; i < self.waypoints.count; i++ {
            let location1 = CLLocation(latitude: self.waypoints[i].latitude, longitude: self.waypoints[i].longitude)
            let location2 = CLLocation(latitude: self.draggingWaypoint.latitude, longitude: self.draggingWaypoint.longitude)
            let meter = location1.distanceFromLocation(location2)
            if meter > 10 { continue }
            index = i
            break
        }
        self.draggingWaypoint = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        if index >= 0 {
            self.waypoints[index] = waypoint
        }
    }


    /// MARK: - private api

    /**
     * draw route
     **/
    private func drawRoute() {
        let pathes = self.encodedPathes()
        for pathString in pathes {
            let path = GMSPath(fromEncodedPath: pathString)
            var line = GMSPolyline(path: path)
            line.strokeWidth = 4.0
            line.tappable = true
            line.map = self
        }

        let locations = self.endLocations()
        let index = locations.count - 1
        if index >= 0 {
            self.drawDestination(location: locations[index])
        }

        self.drawWaypoints()
    }

    /**
     * draw waypoint
     **/
    private func drawWaypoints() {
        for waypoint in self.waypoints {
            self.drawWaypoint(location: waypoint)
        }
    }

    /**
     * draw waypoint marker
     * @param location location
     **/
    private func drawWaypoint(#location: CLLocationCoordinate2D) {
        var marker = HMAWaypointMarker(position: location)
        marker.doSettings()
        marker.map = self
    }

    /**
     * draw destination marker
     * @param location location
     **/
    private func drawDestination(#location: CLLocationCoordinate2D) {
        var marker = HMADestinationMarker(position: location)
        marker.doSettings()
        marker.map = self
    }

    /**
     * draw crimes
     **/
    private func drawCrimes() {
        if self.crimes == nil { return }

        let drawingCrimes = self.crimes as [HMACrimeData]!


/*
        var min = CLLocationCoordinate2DMake(drawingCrimes[0].lat.doubleValue, drawingCrimes[0].long.doubleValue)
        var max = CLLocationCoordinate2DMake(drawingCrimes[0].lat.doubleValue, drawingCrimes[0].long.doubleValue)

        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        for crime in drawingCrimes {
            let lat = crime.lat.doubleValue
            let long = crime.long.doubleValue
            locations.append(CLLocation(latitude: lat, longitude: long))
            weights.append(NSNumber(double: 1.0))
            if lat < min.latitude { min.latitude = lat }
            if long < min.longitude { min.longitude = long }
            if lat > max.latitude { max.latitude = lat }
            if long > max.longitude { max.longitude = long }
        }
        //let center = CLLocationCoordinate2DMake((min.latitude + max.latitude) / 2.0, (min.longitude + max.longitude) / 2.0)
        let center = self.projection.coordinateForPoint(CGPointMake(self.frame.size.width/2.0, self.frame.size.height))
        var marker = HMAHeatmapMarker(position: center)
        marker.map = self
        marker.draggable = false
        marker.boost = 1.0
        marker.weights = weights
        marker.locations = locations
        marker.updateHeatmap()
*/


        for crime in drawingCrimes {
            self.drawCrime(crime)
        }
    }

    /**
     * draw crime marker
     * @param crime HMACrimeData
     **/
    private func drawCrime(crime: HMACrimeData) {
        var marker = HMACrimeMarker(position: CLLocationCoordinate2DMake(crime.lat.doubleValue, crime.long.doubleValue))
        marker.doSettings(crime: crime)
        marker.map = self
    }

    /**
     * return encodedPath
     * @return [String]
     **/
    private func encodedPathes() -> [String] {
        // make pathes
        var pathes = [] as [String]
        let json = self.routeJSON
        if json == nil { return pathes }

        let routes = json!["routes"].arrayValue
        for route in routes {
            let overviewPolyline = route["overview_polyline"].dictionaryValue
            let path = overviewPolyline["points"]!.stringValue
            pathes.append(path)
        }

        return pathes
    }

    /**
     * return end location
     * @return [CLLocationCoordinate2D]
     **/
    private func endLocations() -> [CLLocationCoordinate2D] {
        var locations: [CLLocationCoordinate2D] = []
        let json = self.routeJSON
        if json == nil { return locations }

        let routes = json!["routes"].arrayValue
        for route in routes {
            let legs = route["legs"].arrayValue
            for leg in legs {
                if let locationDictionary = leg["end_location"].dictionary {
                    locations.append(CLLocationCoordinate2D(latitude: locationDictionary["lat"]!.doubleValue, longitude: locationDictionary["lng"]!.doubleValue))
                }
            }
        }
        return locations
    }
}


//class HMAMapView: RMMapView {
//
//
//    /// MARK: - public api
//
//    /**
//     * get map layer
//     * @param annotation annotation
//     * @return RMMapLayer?
//     **/
//    func getLayer(#annotation: RMAnnotation) -> RMMapLayer? {
//        var layer: RMMapLayer? = nil
//
//        // route
//        if annotation.isKindOfClass(HMARouteAnnotation) {
//            let routeAnnotation = annotation as! HMARouteAnnotation
//            layer = routeAnnotation.getLayer(mapView: self)
//        }
//        // heat map
//        else if annotation.isKindOfClass(HMAHeatMapAnnotation) {
//            let heatMapAnnotation = annotation as! HMAHeatMapAnnotation
//            layer = heatMapAnnotation.getLayer(mapView: self)
//        }
//        // cluster
//        else if annotation.isKindOfClass(HMAClusterAnnotation) {
//            let clusterAnnotation = annotation as! HMAClusterAnnotation
//            layer = clusterAnnotation.getLayer()
//        }
//        // crime
//        else if annotation.isKindOfClass(HMACrimeAnnotation) {
//            let crimeAnnotation = annotation as! HMACrimeAnnotation
//            layer = crimeAnnotation.getLayer()
//        }
//        // noise
//        else if annotation.isKindOfClass(HMANoiseAnnotation) {
//            let noiseAnnotation = annotation as! HMANoiseAnnotation
//            layer = noiseAnnotation.getLayer()
//        }
//
//        return layer
//    }
//
//    /**
//     * set route with location points
//     * @param json json
//     **/
//    func setRouteFromGoogleMapAPIDirections(#json: JSON) {
//        // remove
//        self.removeKindOfAnnotationClass(HMARouteAnnotation)
//
//        // add
//        let locationsList = self.locationsListFromGoogleMapAPIDirections(json: json)
//        for locations in locationsList {
//            var annotation = HMARouteAnnotation(
//                mapView: self,
//                coordinate: locations[0].coordinate,
//                title: "Start",
//                locations: locations
//            )
//            annotation.userInfo = locations
//            annotation.setBoundingBoxFromLocations(locations)
//            self.addAnnotation(annotation)
//        }
//    }
//
//    /**
//     * set tempature annotation
//     * @param json json
//     **/
//    func setTempatureAnnotation(#json: JSON) {
//        let sensorDatas = json["sensor_datas"].arrayValue
//        if sensorDatas.count == 0 { return }
//
//        // heatmap
//        var weights: [Double] = []
//        var locations: [CLLocationCoordinate2D] = []
//        for var i = 0; i < sensorDatas.count; i++ {
//            let sensorData = sensorDatas[i]
//            weights.append(sensorData["value"].doubleValue)
//            locations.append(CLLocationCoordinate2DMake(sensorData["lat"].doubleValue, sensorData["long"].doubleValue))
//        }
//
//        let tempatureAnnotation = HMAHeatMapAnnotation(
//            mapView: self,
//            coordinate: CLLocationCoordinate2DMake(0, 0),
//            title: "",
//            locations: locations,
//            weights: weights
//        )
//        self.addAnnotation(tempatureAnnotation)
///*
//        // cluster
//        for sensorData in sensorDatas {
//            let annotation = HMAClusterAnnotation(
//                mapView: self,
//                coordinate: CLLocationCoordinate2DMake(sensorData["lat"].doubleValue, sensorData["long"].doubleValue),
//                title: "",
//                sensorType: HMASensor.SensorType.Temperature,
//                sensorValue: sensorData["value"].doubleValue
//            )
//            self.addAnnotation(annotation)
//        }
//*/
//    }
//
//    /**
//     * set crime annotation
//     * @param json json
//     **/
//    func setCrimeAnnotation(#json: JSON) {
//        self.removeKindOfAnnotationClass(HMACrimeAnnotation)
//
//        let crimeDatas = json["crime_datas"].arrayValue
//        if crimeDatas.count == 0 { return }
//
//        for crimeData in crimeDatas {
//            let annotation = HMACrimeAnnotation(
//                mapView: self,
//                coordinate: CLLocationCoordinate2DMake(crimeData["lat"].doubleValue, crimeData["long"].doubleValue),
//                title: crimeData["desc"].stringValue,
//                desc: crimeData["desc"].stringValue,
//                resolution: crimeData["resolution"].stringValue
//            )
//            self.addAnnotation(annotation)
//        }
//    }
//
//    /**
//     * set noise annotation
//     * @param json json
//     **/
//    func setNoiseAnnotation(#json: JSON) {
//        self.removeKindOfAnnotationClass(HMANoiseAnnotation)
//
//        let crimeDatas = json["sensor_datas"].arrayValue
//        if crimeDatas.count == 0 { return }
//
//        for crimeData in crimeDatas {
//            let annotation = HMANoiseAnnotation(
//                mapView: self,
//                coordinate: CLLocationCoordinate2DMake(crimeData["lat"].doubleValue, crimeData["long"].doubleValue),
//                title: "",
//                soundLevel: crimeData["value"].doubleValue
//            )
//            self.addAnnotation(annotation)
//        }
//    }
//
//    /**
//     * has kind of annotation?
//     * @param annotationClass anotation's class
//     * @return true or false
//     **/
//    func hasKindOfAnnotationClass(annotationClass: AnyClass) -> Bool {
//        for annotation in self.annotations {
//            if annotation.isKindOfClass(annotationClass) { return true }
//        }
//        return false
//    }
//
//    /**
//     * remove kind of annotation
//     * @param annotationClass anotation's class
//     **/
//    func removeKindOfAnnotationClass(annotationClass: AnyClass) {
//        for annotation in self.annotations {
//            if annotation.isKindOfClass(annotationClass) { self.removeAnnotation(annotation as! RMAnnotation) }
//        }
//    }
//
//
//    /// MARK: - private api
//
//    /**
//     * return locations array from google map directions API response JSON
//     * @param json json
//     * @return [[CLLocation]]
//     **/
//    func locationsListFromGoogleMapAPIDirections(#json: JSON) -> [[CLLocation]] {
//        // make locations list
//        var locationsList = [] as [[CLLocation]]
//
//        let routes = json["routes"].arrayValue
//        for route in routes {
//            let legs = route["legs"].arrayValue
//            for leg in legs {
//                // make locations
//                var locations = [] as [CLLocation]
//                // steps
//                let steps = leg["steps"].arrayValue
//                for var i = 0; i < steps.count; i++ {
//                    let step = steps[i]
//                    // start_location
//                    let start = CLLocation(
//                        latitude: step["start_location"].dictionaryValue["lat"]!.doubleValue,
//                        longitude: step["start_location"].dictionaryValue["lng"]!.doubleValue
//                    )
//                    locations.append(start)
//                    // end_location
//                    if i == steps.count - 1 {
//                        let end = CLLocation(
//                            latitude: step["end_location"].dictionaryValue["lat"]!.doubleValue,
//                            longitude: step["end_location"].dictionaryValue["lng"]!.doubleValue
//                        )
//                        locations.append(end)
//                    }
//                }
//                locationsList.append(locations)
//            }
//        }
//
//        return locationsList
//    }
//
//}
