/// MARK: - HMAMapView
class HMAMapView: GMSMapView {

    /// MARK: - properties

    static let sharedInstance = HMAMapView()

    /// overlays
    private var overlays: [GMSOverlay] = []
    // tile layer
    private var tileLayer: GMSURLTileLayer!

    /// dragging waypoint
    private var draggingWaypoint: CLLocationCoordinate2D?
    /// waypoints for routing
    var waypoints: [CLLocationCoordinate2D] = []
    /// route json
    private var routeJSON: JSON?

    /// sensor evaluation
    private let sensorEvaluation = HMASensorEvaluation()
    /// wheel evaluation
    private let wheelEvaluation = HMAWheelEvaluation()

    /// crimes
    private var crimeDatas: [HMACrimeData]! = []
    /// humidityDatas
    private var humidityDatas: [HMASensorData]! = []
    /// temperatureDatas
    private var temperatureDatas: [HMASensorData]! = []
    /// accelDatas
    private var accelDatas: [HMAWheelData]! = []
    /// torqueDatas
    private var torqueDatas: [HMAWheelData]! = []

    /// should draw crime
    var shouldDrawCrimes = false
    /// should draw comfort
    var shouldDrawComfort = false
    /// should draw wheel
    var shouldDrawWheel = false


    /// MARK: - public api

    /**
     * do settings
     **/
    func doSettings() {
        self.mapType = kGMSTypeNone // kGMSTypeNormal, kGMSTypeTerrain, kGMSTypeSatellite, kGMSTypeSatellite, kGMSTypeHybrid, kGMSTypeNone
        self.myLocationEnabled = true
        self.settings.compassButton = false
        self.settings.myLocationButton = false
        self.settings.indoorPicker = false
        self.buildingsEnabled = false
        self.accessibilityElementsHidden = true
        self.trafficEnabled = true

        var urls : GMSTileURLConstructor = { x, y, zoom in
/*
            //return NSURL(string: "http://tile.openstreetmap.org/\(zoom)/\(x)/\(y).png")
            //return NSURL(string: "http://\(s).tiles.wmflabs.org/bw-mapnik/\(zoom)/\(x)/\(y).png")
            //return NSURL(string: "http://a.tile.thunderforest.com/transport/\(zoom)/\(x)/\(y).png")
            //return NSURL(string: "http://a.tile.thunderforest.com/transport/\(zoom)/\(x)/\(y).png")
            //return NSURL(string: "http://129.206.74.245/tiles/roadsg/x=\(x)&y=\(y)&z=\(zoom)")
*/
            return NSURL(string: "\(HMAMapbox.API.Tiles)\(HMAMapbox.MapID)/\(zoom)/\(x)/\(y).png?access_token=\(HMAMapbox.AccessToken)")
        }
        self.tileLayer = GMSURLTileLayer(URLConstructor: urls)
        self.tileLayer.zIndex = HMAGoogleMap.ZIndex.Tile
        self.tileLayer.map = self
    }

    /**
     * update what map draws
     **/
    func updateWhatMapDraws() {
        let min = self.minimumCoordinate(mapViewPoints: [ CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), ])
        let max = self.maximumCoordinate(mapViewPoints: [ CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), ])

        // crime
        if self.shouldDrawCrimes {
            self.crimeDatas = HMACrimeData.fetch(minimumCoordinate: min, maximumCoordinate: max)
        }
        // comfort
        if self.shouldDrawComfort {
            self.humidityDatas = HMASensorData.fetch(sensorType: HMASensor.SensorType.Humidity, minimumCoordinate: min, maximumCoordinate: max)
            self.temperatureDatas = HMASensorData.fetch(sensorType: HMASensor.SensorType.Temperature, minimumCoordinate: min, maximumCoordinate: max)
        }
        // wheel
        if self.shouldDrawWheel {
            self.accelDatas = HMAWheelData.fetch(dataType: HMAWheel.DataType.Acceleration, minimumCoordinate: min, maximumCoordinate: max)
            self.torqueDatas = HMAWheelData.fetch(dataType: HMAWheel.DataType.RiderTorque, minimumCoordinate: min, maximumCoordinate: max)
        }
    }

    /**
     * draw all markers, route, overlays and something like that
     **/
    func draw() {
        // clear
        for overlay in self.overlays { overlay.map = nil }
        self.overlays = []

        // crime
        if self.shouldDrawCrimes {
            self.drawCrimeMakers()
            //self.drawCrimeHeatmap()
        }
        // comfort
        if self.shouldDrawComfort {
            self.drawHeatIndexHeatmap()
        }
        // wheel
        if self.shouldDrawWheel {
            self.drawWheelPolyline()
        }
        // yelp
        self.drawYelp()

        // route
        if self.routeJSON != nil {
            self.drawRoute()
        }
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
     * get centerCoordinate
     * @return CLLocationCoordinate2D
     **/
    func centerCoordinate() -> CLLocationCoordinate2D {
        return self.projection.coordinateForPoint(self.center)
    }

    /**
     * get minimumCoordinate
     * @param mapViewPoints coordinates on GMSMapView
     * @return CLLocationCoordinate2D
     **/
    func minimumCoordinate(#mapViewPoints: [CGPoint]) -> CLLocationCoordinate2D {
        var min = self.projection.coordinateForPoint(mapViewPoints[0])
        for point in mapViewPoints {
            let coordinate = self.projection.coordinateForPoint(point)
            if min.latitude > coordinate.latitude { min.latitude = coordinate.latitude }
            if min.longitude > coordinate.longitude { min.longitude = coordinate.longitude }
        }
        return min
    }

    /**
     * get maximumCoordinate
     * @param mapViewPoints coordinates on GMSMapView
     * @return CLLocationCoordinate2D
     **/
    func maximumCoordinate(#mapViewPoints: [CGPoint]) -> CLLocationCoordinate2D {
        var max = self.projection.coordinateForPoint(mapViewPoints[0])
        for point in mapViewPoints {
            let coordinate = self.projection.coordinateForPoint(point)
            if max.latitude < coordinate.latitude { max.latitude = coordinate.latitude }
            if max.longitude < coordinate.longitude { max.longitude = coordinate.longitude }
        }
        return max
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
            let location2 = CLLocation(latitude: self.draggingWaypoint!.latitude, longitude: self.draggingWaypoint!.longitude)
            let meter = location1.distanceFromLocation(location2)
            if meter > 10 { continue }
            index = i
            break
        }
        self.draggingWaypoint = nil
        if index >= 0 {
            self.waypoints[index] = waypoint
        }
    }

    /**
     * is dragging now?
     * @return BOOL
     **/
    func isDraggingNow() -> Bool {
        return (self.draggingWaypoint != nil)
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
            line.zIndex = HMAGoogleMap.ZIndex.Route
            self.overlays.append(line)
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
        marker.zIndex = HMAGoogleMap.ZIndex.Waypoint
        self.overlays.append(marker)
    }

    /**
     * draw destination marker
     * @param location location
     **/
    private func drawDestination(#location: CLLocationCoordinate2D) {
        var marker = HMADestinationMarker(position: location)
        marker.doSettings()
        marker.map = self
        marker.zIndex = HMAGoogleMap.ZIndex.Destination
        self.overlays.append(marker)
    }

    /**
     * draw crimes
     **/
    private func drawCrimeMakers() {
        if self.crimeDatas.count == 0 { return }

        for crime in self.crimeDatas {
            self.drawCrimeMaker(crime: crime)
        }
    }

    /**
     * draw crime marker
     * @param crime HMACrimeData
     **/
    private func drawCrimeMaker(#crime: HMACrimeData) {
        var marker = HMACrimeMarker(position: CLLocationCoordinate2DMake(crime.lat.doubleValue, crime.long.doubleValue))
        marker.doSettings(crime: crime)
        marker.map = self
        marker.zIndex = HMAGoogleMap.ZIndex.Crime
        self.overlays.append(marker)
    }

    /**
     * draw yelp
     **/
    private func drawYelp() {
        let yelpDatas = HMAYelpClient.sharedInstance.yelpDatas
        if yelpDatas == nil { return }

        for yelpData in yelpDatas! {
            var marker = HMAYelpMaker(position: yelpData.coordinate)
            marker.doSettings(yelpData: yelpData)
            marker.map = self
            marker.zIndex = HMAGoogleMap.ZIndex.Yelp
            self.overlays.append(marker)
        }
    }

    /**
     * draw crime heatmap
     **/
    private func drawCrimeHeatmap() {
        if self.crimeDatas.count == 0 { return }

        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        let boost: Float = 1.0
        for crime in self.crimeDatas {
            locations.append(CLLocation(latitude: crime.lat.doubleValue, longitude: crime.long.doubleValue))
            weights.append(NSNumber(double: 1.0))
        }

        let overlay = GMSGroundOverlay(
            position: self.projection.coordinateForPoint(CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)),
            icon: UIImage.crimeHeatmapImage(mapView: self, locations: locations, weights: weights, boost: boost),
            zoomLevel: CGFloat(self.camera.zoom)
        )
        overlay.bearing = self.camera.bearing
        overlay.map = self
        self.overlays.append(overlay)
    }

    /**
     * draw heat index heatmap
     **/
    private func drawHeatIndexHeatmap() {
        // make heat index list
        var heatIndexDatas: [HMASensorData] = []
        var humidityIndex = 0
        for var i = 0; i < self.temperatureDatas.count; i++ {
            var temperatureData = self.temperatureDatas[i]
            for var j = humidityIndex; j < self.humidityDatas.count; j++ {
                var humidityData = self.humidityDatas[i]
                if temperatureData.lat != humidityData.lat ||
                   temperatureData.long != humidityData.long ||
                   temperatureData.timestamp != humidityData.timestamp {
                       continue
                }
                humidityIndex = j
                heatIndexDatas.append(temperatureData)
                heatIndexDatas.append(humidityData)
                break
            }
        }

        // make heatmap
        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        let boost: Float = 1.0
        for var i = 0; i < heatIndexDatas.count; i += 2 {
            locations.append(CLLocation(latitude: heatIndexDatas[i].lat.doubleValue, longitude: heatIndexDatas[i].long.doubleValue))
            weights.append(NSNumber(double: self.sensorEvaluation.getHeatIndexWeight(humidity: heatIndexDatas[i+1].value.doubleValue, temperature: heatIndexDatas[i].value.doubleValue)))
        }
        let overlay = GMSGroundOverlay(
            position: self.projection.coordinateForPoint(CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)),
            icon: UIImage.heatIndexHeatmapImage(mapView: self, locations: locations, weights: weights, boost: boost),
            zoomLevel: CGFloat(self.camera.zoom)
        )
        overlay.bearing = self.camera.bearing
        overlay.map = self
        overlay.zIndex = HMAGoogleMap.ZIndex.HeatIndex
        self.overlays.append(overlay)
/*
        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        let boost: Float = 1.0
        for humidityData in self.humidityDatas {
            let temperatures = self.temperatureDatas.filter({ (sensorData: HMASensorData) -> Bool in
                return (sensorData.lat == humidityData.lat && sensorData.long == humidityData.long && sensorData.timestamp == humidityData.timestamp)
            })
            for temperatureData in temperatures {
                locations.append(CLLocation(latitude: humidityData.lat.doubleValue, longitude: humidityData.long.doubleValue))
                weights.append(NSNumber(double: self.sensorEvaluation.getHeatIndexWeight(humidity: humidityData.value.doubleValue, temperature: temperatureData.value.doubleValue)))
            }
        }

        let overlay = GMSGroundOverlay(
            position: self.projection.coordinateForPoint(CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)),
            icon: UIImage.heatmapImage(mapView: self, locations: locations, weights: weights, boost: boost),
            zoomLevel: CGFloat(self.camera.zoom)
        )
        overlay.bearing = self.camera.bearing
        overlay.map = self
*/
    }

    /**
     * draw data visualization by wheel data and polyline
     **/
    private func drawWheelPolyline() {
        // draw line
        func drawPolyline(#map: HMAMapView, coordinateA: CLLocationCoordinate2D, coordinateB: CLLocationCoordinate2D, color: UIColor) {
            var path = GMSMutablePath()
            path.addCoordinate(coordinateA)
            path.addCoordinate(coordinateB)
            var line = GMSPolyline(path: path)
            line.strokeColor = color
            line.strokeWidth = 7.5
            line.tappable = false
            line.map = map
            line.zIndex = HMAGoogleMap.ZIndex.Wheel
            self.overlays.append(line)
        }

        // Acceleration
        for var i = 0; i < self.accelDatas.count - 1; i++ {
            let locationA = CLLocation(latitude: self.accelDatas[i].lat.doubleValue, longitude: self.accelDatas[i].long.doubleValue)
            let locationB = CLLocation(latitude: self.accelDatas[i+1].lat.doubleValue, longitude: self.accelDatas[i+1].long.doubleValue)
            if HMAMapMath.miles(locationA: locationA, locationB: locationB) > HMAWheel.MaxDistanceForVisualization { continue }

            drawPolyline(
                map: self,
                locationA.coordinate,
                locationB.coordinate,
                self.wheelEvaluation.getMinusAccelerationColor(accelA: self.accelDatas[i].value.doubleValue, accelB: self.accelDatas[i+1].value.doubleValue)
            )
        }
        // RiderTorque
        for var i = 0; i < self.torqueDatas.count - 1; i++ {
            let locationA = CLLocation(latitude: self.torqueDatas[i].lat.doubleValue, longitude: self.torqueDatas[i].long.doubleValue)
            let locationB = CLLocation(latitude: self.torqueDatas[i+1].lat.doubleValue, longitude: self.torqueDatas[i+1].long.doubleValue)
            if HMAMapMath.miles(locationA: locationA, locationB: locationB) > HMAWheel.MaxDistanceForVisualization { continue }

            drawPolyline(
                map: self,
                locationA.coordinate,
                locationB.coordinate,
                self.wheelEvaluation.getRiderTorqueColor(torqueA: self.torqueDatas[i].value.doubleValue, torqueB: self.torqueDatas[i+1].value.doubleValue)
            )
        }
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
