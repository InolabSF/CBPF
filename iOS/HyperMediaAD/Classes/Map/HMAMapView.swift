/// MARK: - HMAMapView
class HMAMapView: GMSMapView {

    /// MARK: - properties

    static let sharedInstance = HMAMapView()

    /// dragging waypoint
    private var draggingWaypoint: CLLocationCoordinate2D?
    /// waypoints for routing
    var waypoints: [CLLocationCoordinate2D] = []
    /// route json
    private var routeJSON: JSON?
    /// visualization type
//    private var visualizationType = HMAGoogleMap.Visualization.None
    /// comfort
//    private let comfort = HMAComfort()

    /// crimes
    private var crimeDatas: [HMACrimeData]?
    /// sensorDatas
    private var sensorDatas: [HMASensorData]?

    /// should draw crime
    var shouldDrawCrimes = false
    /// should draw comfort
    var shouldDrawComfort = false
    /// should draw bike
    var shouldDrawBike = false


    /// MARK: - public api

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
            self.sensorDatas = []
            self.sensorDatas += HMASensorData.fetch(sensorType: HMASensor.SensorType.Temperature, minimumCoordinate: min, maximumCoordinate: max)
            self.sensorDatas += HMASensorData.fetch(sensorType: HMASensor.SensorType.Humidity, minimumCoordinate: min, maximumCoordinate: max)
        }

        // bike
        if self.shouldDrawBike {
        }
/*
        // sensor data
        var sensorTypes = self.getSensorTypes()
        var sensorDatas: [HMASensorData] = []
        for sensorType in sensorTypes {
            let datas = HMASensorData.fetch(sensorType: sensorType, minimumCoordinate: min, maximumCoordinate: max)
            sensorDatas += datas
        }
        self.setSensorDatas(sensorDatas)
*/
    }

    /**
     * draw all markers, route, overlays and something like that
     **/
    func draw() {
        // clear
        self.clear()

        // crime
        if self.shouldDrawCrimes {
            self.drawCrimeMakers()
        }

        // comfort
        if self.shouldDrawComfort {
            self.drawHeatIndexHeatmap()
        }
/*
        switch (self.visualizationType) {
            // crime
            case HMAGoogleMap.Visualization.CrimePoint:
                self.drawCrimeMakers()
                break
            case HMAGoogleMap.Visualization.CrimeHeatmap:
                self.drawCrimeHeatmap()
                break
            case HMAGoogleMap.Visualization.CrimeCluster:
                self.drawCrimeCluster()
                break
            // sensor data
            case HMAGoogleMap.Visualization.NoisePoint, HMAGoogleMap.Visualization.Pm25Point, HMAGoogleMap.Visualization.HeatIndexPoint:
                self.drawSensorMakers()
                break
            case HMAGoogleMap.Visualization.NoiseHeatmap, HMAGoogleMap.Visualization.Pm25Heatmap, HMAGoogleMap.Visualization.HeatIndexHeatmap:
                self.drawSensorHeatmap()
                break
            default:
                break
        }
*/
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
     * set crimes
     * @param crimes [HMACrimeData]
     **/
/*
    func setCrimes(crimes: [HMACrimeData]?) {
        self.crimes = crimes
    }
*/
    /**
     * set sensorDatas
     * @param sensorDatas [HMASensorData]
     **/
/*
    func setSensorDatas(sensorDatas: [HMASensorData]?) {
        self.sensorDatas = sensorDatas
    }
*/

//    /**
//     * set visualization Type
//     * @param visualizationType HMAGoogleMap.Visualization
//     **/
//    func setVisualizationType(visualizationType: HMAGoogleMap.Visualization) {
//        self.visualizationType = visualizationType
//
//        HMAYelpClient.sharedInstance.yelpDatas = nil
//        switch (self.visualizationType) {
//            case HMAGoogleMap.Visualization.CrimePoint, HMAGoogleMap.Visualization.CrimeHeatmap, HMAGoogleMap.Visualization.CrimeCluster:
//                HMACrimeData.requestToGetCrimeData()
//                break
//            case HMAGoogleMap.Visualization.NoisePoint, HMAGoogleMap.Visualization.NoiseHeatmap:
////                HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Noise)
//                break
//            case HMAGoogleMap.Visualization.Pm25Point, HMAGoogleMap.Visualization.Pm25Heatmap:
////                HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Pm25)
//                break
//            case HMAGoogleMap.Visualization.HeatIndexPoint, HMAGoogleMap.Visualization.HeatIndexHeatmap:
////                HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Humidity)
////                HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Temperature)
//                break
//            default:
//                self.crimeDatas = []
//                self.sensorDatas = []
//                break
//        }
//    }

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
    private func drawCrimeMakers() {
        if self.crimeDatas == nil { return }

        let drawingCrimes = self.crimeDatas as [HMACrimeData]!
        if drawingCrimes.count == 0 { return }

        for crime in drawingCrimes {
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
    }

    /**
     * draw sensorDatas
     **/
//    private func drawSensorMakers() {
///*
//        if self.sensorDatas == nil { return }
//
//        var drawingSensorDatas = self.sensorDatas as [HMASensorData]!
//        if drawingSensorDatas.count == 0 { return }
//*/
///*
//        if self.visualizationType == HMAGoogleMap.Visualization.HeatIndexHeatmap {
//            self.drawHeatIndexMarkers()
//        }
//        else {
//            for sensorData in drawingSensorDatas {
//                self.drawSensorMaker(sensorData: sensorData)
//            }
//        }
//*/
//    }

//    /**
//     * draw sensorData marker
//     * @param sensorData HMASensorData
//     **/
//    private func drawSensorMaker(#sensorData: HMASensorData) {
//        var marker = HMASensorMarker(position: CLLocationCoordinate2DMake(sensorData.lat.doubleValue, sensorData.long.doubleValue))
//        marker.doSettings(sensorData: sensorData)
//        marker.map = self
//    }

//    /**
//     * draw heat index marker
//     **/
//    private func drawHeatIndexMarkers() {
////        let humidityDatas = drawingSensorDatas.filter({ (sensorData: HMASensorData) -> Bool in return (sensorData.sensor_id == NSNumber(integer: HMASensor.SensorType.Humidity)) })
////        let temperatureDatas = drawingSensorDatas.filter({ (sensorData: HMASensorData) -> Bool in return (sensorData.sensor_id == NSNumber(integer: HMASensor.SensorType.Temperature)) })
//    }

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
        }
    }

    /**
     * draw crime heatmap
     **/
    private func drawCrimeHeatmap() {
        if self.crimeDatas == nil { return }

        let drawingCrimes = self.crimeDatas as [HMACrimeData]!
        if drawingCrimes.count == 0 { return }

        var min = self.minimumCoordinate(mapViewPoints: [ CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), ])
        var max = self.maximumCoordinate(mapViewPoints: [ CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), ])

        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        let boost: Float = 1.0
        for crime in drawingCrimes {
            locations.append(CLLocation(latitude: crime.lat.doubleValue, longitude: crime.long.doubleValue))
            weights.append(NSNumber(double: 1.0))
        }

        let overlay = GMSGroundOverlay(
            position: self.projection.coordinateForPoint(CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)),
            icon: UIImage.heatmapImage(mapView: self, locations: locations, weights: weights, boost: boost),
            zoomLevel: CGFloat(self.camera.zoom)
        )
        overlay.bearing = self.camera.bearing
        overlay.map = self
    }

    /**
     * draw sensor heatmap
     **/
    private func drawSensorHeatmap() {
/*
        if self.sensorDatas == nil { return }

        let drawingSensorDatas = self.sensorDatas as [HMASensorData]!
        if drawingSensorDatas.count == 0 { return }

        if self.visualizationType == HMAGoogleMap.Visualization.HeatIndexHeatmap {
            self.drawHeatIndexHeatmap()
            return
        }

        var min = self.minimumCoordinate(mapViewPoints: [ CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), ])
        var max = self.maximumCoordinate(mapViewPoints: [ CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), ])

        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        let boost: Float = 1.0
        for sensorData in drawingSensorDatas {
            locations.append(CLLocation(latitude: sensorData.lat.doubleValue, longitude: sensorData.long.doubleValue))
            weights.append(NSNumber(double: self.comfort.getWeight(visualization: self.visualizationType, value: sensorData.value.doubleValue)))
        }

        let overlay = GMSGroundOverlay(
            bounds: GMSCoordinateBounds(coordinate: min, coordinate: max),
            icon: UIImage.heatmapImage(mapView: self, locations: locations, weights: weights, boost: boost)
        )
        overlay.bearing = 0
        overlay.map = self
*/
    }

    /**
     * draw heat index heatmap
     **/
    private func drawHeatIndexHeatmap() {
/*
        let humidityDatas = self.sensorDatas!.filter({ (sensorData: HMASensorData) -> Bool in return (sensorData.sensor_id == NSNumber(integer: HMASensor.SensorType.Humidity)) })
        let temperatureDatas = self.sensorDatas!.filter({ (sensorData: HMASensorData) -> Bool in return (sensorData.sensor_id == NSNumber(integer: HMASensor.SensorType.Temperature)) })

        var min = self.minimumCoordinate(mapViewPoints: [ CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), ])
        var max = self.maximumCoordinate(mapViewPoints: [ CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), ])

        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        let boost: Float = 1.0
        for humidityData in humidityDatas {
            let temperatures = temperatureDatas.filter({ (sensorData: HMASensorData) -> Bool in
                return (sensorData.lat == humidityData.lat && sensorData.long == humidityData.long && sensorData.timestamp == humidityData.timestamp)
            })
            for temperatureData in temperatures {
                locations.append(CLLocation(latitude: humidityData.lat.doubleValue, longitude: humidityData.long.doubleValue))
                weights.append(NSNumber(double: self.comfort.getHeatIndexWeight(humidity: humidityData.value.doubleValue, temperature: temperatureData.value.doubleValue)))
            }
        }

        let overlay = GMSGroundOverlay(
            bounds: GMSCoordinateBounds(coordinate: min, coordinate: max),
            icon: UIImage.heatmapImage(mapView: self, locations: locations, weights: weights, boost: boost)
        )
        overlay.bearing = 0
        overlay.map = self
*/
    }

    /**
     * draw crime cluster
     **/
/*
    private func drawCrimeCluster() {
        if self.crimeDatas == nil { return }

        let drawingCrimes = self.crimeDatas as [HMACrimeData]!
        if drawingCrimes.count == 0 { return }

        let column = 4
        let row = 6

        let startColumn = 0 - column / 2
        let startRow = 0 - row / 2
        let endColumn = column + column / 2
        let endRow = row + row / 2

        // grid
        self.drawGrid(column: column, row: row)

        // marker
        for var x = startColumn; x < endColumn; x++ {
            let minX = self.frame.size.width * CGFloat(x) / CGFloat(column)
            let maxX = self.frame.size.width * CGFloat(x + 1) / CGFloat(column)
            for var y = startRow; y < endRow; y++ {
                let minY = self.frame.size.height * CGFloat(y) / CGFloat(row)
                let maxY = self.frame.size.height * CGFloat(y + 1) / CGFloat(row)
                var marker = HMAClusterMarker(mapView: self, minimumPoint: CGPointMake(minX, minY), maximumPoint: CGPointMake(maxX, maxY), crimes: drawingCrimes)
                marker.map = self
            }
        }
    }
*/

    /**
     * draw grid
     * @param column grid number of column
     * @param row grid number of row
     **/
    private func drawGrid(#column: Int, row: Int) {
        let startColumn = 0 - column / 2
        let startRow = 0 - row / 2
        let endColumn = column + column / 2
        let endRow = row + row / 2

        for var x = startColumn; x < endColumn; x++ {
            let offsetX = self.frame.size.width * CGFloat(x) / CGFloat(column)
            var path = GMSMutablePath()
            path.addCoordinate(self.projection.coordinateForPoint(CGPointMake(offsetX, 0)))
            path.addCoordinate(self.projection.coordinateForPoint(CGPointMake(offsetX, self.frame.size.height)))
            var line = GMSPolyline(path: path)
            line.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
            line.strokeWidth = 1.0
            line.tappable = false
            line.map = self
        }
        for var y = startRow; y < endRow; y++ {
            let yOffset = self.frame.size.height * CGFloat(y) / CGFloat(row)
            var path = GMSMutablePath()
            path.addCoordinate(self.projection.coordinateForPoint(CGPointMake(0, yOffset)))
            path.addCoordinate(self.projection.coordinateForPoint(CGPointMake(self.frame.size.width, yOffset)))
            var line = GMSPolyline(path: path)
            line.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
            line.strokeWidth = 1.0
            line.tappable = false
            line.map = self
        }
    }

    /**
     * get sensorTypes from visualizationType
     * @return [HMASensor.SensorType]
     **/
/*
    private func getSensorTypes() -> [Int] {
        // sensor data
        var sensorType = HMASensor.SensorType.None
        switch (self.visualizationType) {
            // noise
            case HMAGoogleMap.Visualization.NoisePoint, HMAGoogleMap.Visualization.NoiseHeatmap:
                sensorType = HMASensor.SensorType.Noise
                break
            // PM2.5
            case HMAGoogleMap.Visualization.Pm25Point, HMAGoogleMap.Visualization.Pm25Heatmap:
                sensorType = HMASensor.SensorType.Pm25
                break
            // HeatIndexPoint, HeatIndexHeatmap
            case HMAGoogleMap.Visualization.HeatIndexPoint, HMAGoogleMap.Visualization.HeatIndexHeatmap:
                return [HMASensor.SensorType.Humidity, HMASensor.SensorType.Temperature]
            default:
                break
        }
        return [sensorType]
    }
*/
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
