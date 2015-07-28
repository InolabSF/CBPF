/// MARK: - HMAMapView
class HMAMapView: GMSMapView {

    /// MARK: - properties

    static let sharedInstance = HMAMapView()

    // tile layer
    private var tileLayer: GMSURLTileLayer?

    /// overlays
    private var overlayManager = HMAMapOverlayManager()

    /// editing marker
    private var editingMarker: GMSMarker?
    /// editing coordinate
    private var editingCoordinate: CLLocationCoordinate2D?
    /// destinations for routing
    var destinations: [CLLocationCoordinate2D] = []
    /// waypoints for routing
    var waypoints: [CLLocationCoordinate2D] = []
    /// route json
    private var routeJSONs: [JSON]?

    /// sensor evaluation
    private let sensorEvaluation = HMASensorEvaluation()
    /// wheel evaluation
    private let wheelEvaluation = HMAWheelEvaluation()

    /// crimes
    private var crimeDatas: [HMACrimeData]! = []
    /// heatIndexDatas
    private var heatIndexDatas: [HMAHeatIndexData]! = []
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

//    /// drawing rect
//    var drawingRect: CGRect? = nil
//    /// drawing zoom
//    var drawingZoom: Float? = nil


    /// MARK: - public api

    /**
     * do settings
     **/
    func doSettings() {
        // map
        self.myLocationEnabled = true
        self.settings.compassButton = false
        self.settings.myLocationButton = true
        self.settings.indoorPicker = false
        self.buildingsEnabled = false
        self.accessibilityElementsHidden = true
    }

    /**
     * update what map draws
     **/
    func updateWhatMapDraws() {
        let points = [
/*
            CGPointMake(-self.frame.size.width*0.5, -self.frame.size.height*0.5),
            CGPointMake(-self.frame.size.width*0.5, self.frame.size.height*1.5),
            CGPointMake(self.frame.size.width*1.5, -self.frame.size.height*0.5),
            CGPointMake(self.frame.size.width*1.5, self.frame.size.height*1.5),
*/
            CGPointMake(0, 0),
            CGPointMake(0, self.frame.size.height),
            CGPointMake(self.frame.size.width, 0),
            CGPointMake(self.frame.size.width, self.frame.size.height),
        ]
        let min = self.minimumCoordinate(mapViewPoints: points)
        let max = self.maximumCoordinate(mapViewPoints: points)

        //var crimeInterval = 0.0
        //var comfortInterval = 0.0
        //var wheelInterval = 0.0

        // crime
        if self.shouldDrawCrimes {
            //var start = NSDate()
            self.crimeDatas = HMACrimeData.fetch(minimumCoordinate: min, maximumCoordinate: max)
            //crimeInterval = NSDate().timeIntervalSinceDate(start)
        }
        else { self.crimeDatas = [] }
        // comfort
        if self.shouldDrawComfort {
            //var start = NSDate()
            self.heatIndexDatas = HMAHeatIndexData.fetch(minimumCoordinate: min, maximumCoordinate: max)
            //comfortInterval = NSDate().timeIntervalSinceDate(start)
        }
        else { self.heatIndexDatas = [] }
        // wheel
        if self.shouldDrawWheel {
            //var start = NSDate()
            self.accelDatas = HMAWheelData.fetch(dataType: HMAWheel.DataType.Acceleration, minimumCoordinate: min, maximumCoordinate: max)
            self.torqueDatas = HMAWheelData.fetch(dataType: HMAWheel.DataType.RiderTorque, minimumCoordinate: min, maximumCoordinate: max)
            //wheelInterval = NSDate().timeIntervalSinceDate(start)
        }
        else {
            self.accelDatas = []
            self.torqueDatas = []
        }

        //HMALOG("DB crime:\(crimeInterval), comfort:\(comfortInterval), wheel:\(wheelInterval)")
    }

    /**
     * draw all markers, route, overlays and something like that
     **/
    func draw() {
        // clear
        self.overlayManager.clearOverlays()

        //var crimeInterval = 0.0
        //var comfortInterval = 0.0
        //var wheelInterval = 0.0

        let zoom = self.camera.zoom

        // crime
        if zoom > HMAGoogleMap.Zoom.MinOfCrime && self.shouldDrawCrimes {
            //var start = NSDate()
            self.drawCrimeMakers()
            //crimeInterval = NSDate().timeIntervalSinceDate(start)
        }
        // comfort
        if zoom > HMAGoogleMap.Zoom.MinOfComfort && self.shouldDrawComfort {
            //var start = NSDate()
            self.drawHeatIndexHeatmap()
            //comfortInterval = NSDate().timeIntervalSinceDate(start)
        }
        // wheel
        if zoom > HMAGoogleMap.Zoom.MinOfWheel && self.shouldDrawWheel {
            //var start = NSDate()
            self.drawWheelPolyline()
            //wheelInterval = NSDate().timeIntervalSinceDate(start)
        }

        //HMALOG("Rendering crime:\(crimeInterval), comfort:\(comfortInterval), wheel:\(wheelInterval)")

        // destination
        self.drawDestinations()

        // route
        if self.routeJSONs != nil {
            self.drawRoute()
        }
    }

    /**
     * set userInterfaceMode
     * @param mode UserInterface.Mode
     **/
    func setUserInterfaceMode(mode: Int) {
        // tile
        if self.tileLayer != nil { self.tileLayer!.map = nil }
        if mode == HMAUserInterface.Mode.SetRoute {
            self.mapType = kGMSTypeNone
            if self.tileLayer == nil {
                var urls : GMSTileURLConstructor = { x, y, zoom in
                    return NSURL(string: "\(HMAMapbox.API.Tiles)\(HMAMapbox.MapID)/\(zoom)/\(x)/\(y).png?access_token=\(HMAMapbox.AccessToken)")
                }
                self.tileLayer = GMSURLTileLayer(URLConstructor: urls)
                self.tileLayer!.zIndex = HMAGoogleMap.ZIndex.Tile
            }
            self.tileLayer!.map = self
        }
        else {
            self.mapType = kGMSTypeNormal
        }

        // if views are hidden or not
        if mode == HMAUserInterface.Mode.SetDestinations {
            self.shouldDrawCrimes = false
            self.shouldDrawComfort = false
            self.shouldDrawWheel = false
        }
        else if mode == HMAUserInterface.Mode.SetRoute {
            self.shouldDrawCrimes = true
            self.shouldDrawComfort = true
            self.shouldDrawWheel = true
        }
        else if mode == HMAUserInterface.Mode.Cycle {
            self.shouldDrawCrimes = false
            self.shouldDrawComfort = false
            self.shouldDrawWheel = false
        }
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
     * add destination for routing
     * @param destination destination
     **/
    func appendDestination(destination: CLLocationCoordinate2D) {
        self.destinations.append(destination)
    }

    /**
     * remove all destination for routing
     **/
    func removeAllDestinations() {
        self.routeJSONs = nil
        self.removeAllWaypoints()
        self.destinations = []
    }

    /**
     * start Editing Marker
     * @param marker GMSMarker
     **/
    func startEditingMarker(marker: GMSMarker) {
        self.editingMarker = marker
        self.editingCoordinate = marker.position
    }

    /**
     * end editing marker
     **/
    func endEditingMarker() {
        self.editingMarker = nil
        self.editingCoordinate = nil
    }

    /**
     * delete editing marker
     **/
    func deleteEditingMarker() {
        if !(self.isEditingMarkerNow()) {
            self.endEditingMarker()
            return
        }

        // set type of editing marker
        var coordinates: [CLLocationCoordinate2D]? = nil
        if self.editingMarker!.isKindOfClass(HMADestinationMarker) { coordinates = self.destinations }
        else if self.editingMarker!.isKindOfClass(HMAWaypointMarker) { coordinates = self.waypoints }
        if coordinates == nil {
            self.endEditingMarker()
            return
        }

        // remove
        var deletingIndex: Int? = nil
        for var i = 0; i < coordinates!.count; i++ {
            let location1 = CLLocation(latitude: coordinates![i].latitude, longitude: coordinates![i].longitude)
            let location2 = CLLocation(latitude: self.editingCoordinate!.latitude, longitude: self.editingCoordinate!.longitude)
            let meter = location1.distanceFromLocation(location2)
            if meter > 10 { continue }
            deletingIndex = i
            break
        }
        if deletingIndex != nil { coordinates!.removeAtIndex(deletingIndex!) }
        if self.editingMarker!.isKindOfClass(HMADestinationMarker) { self.destinations = coordinates! }
        else if self.editingMarker!.isKindOfClass(HMAWaypointMarker) { self.waypoints = coordinates! }

        self.endEditingMarker()
    }

    /**
     * end dragging editing marker
     * @param marker GMSMarker
     **/
    func endDraggingMarker(marker: GMSMarker) {
        if !(self.isEditingMarkerNow()) {
            self.endEditingMarker()
            return
        }

        // set type of editing marker
        var coordinates: [CLLocationCoordinate2D]? = nil
        if self.editingMarker!.isKindOfClass(HMADestinationMarker) { coordinates = self.destinations }
        else if self.editingMarker!.isKindOfClass(HMAWaypointMarker) { coordinates = self.waypoints }
        if coordinates == nil {
            self.endEditingMarker()
            return
        }

        // remove
        var draggingIndex: Int? = nil
        for var i = 0; i < coordinates!.count; i++ {
            let location1 = CLLocation(latitude: coordinates![i].latitude, longitude: coordinates![i].longitude)
            let location2 = CLLocation(latitude: self.editingCoordinate!.latitude, longitude: self.editingCoordinate!.longitude)
            let meter = location1.distanceFromLocation(location2)
            if meter > 10 { continue }
            draggingIndex = i
            break
        }
        if draggingIndex != nil { coordinates![draggingIndex!] = marker.position }
        if self.editingMarker!.isKindOfClass(HMADestinationMarker) { self.destinations = coordinates! }
        else if self.editingMarker!.isKindOfClass(HMAWaypointMarker) { self.waypoints = coordinates! }

        self.endEditingMarker()
    }

    /**
     * add waypoint for routing
     * @param waypoint waypoint
     **/
    func appendWaypoint(waypoint: CLLocationCoordinate2D) {
        self.waypoints.append(waypoint)
    }

    /**
     * remove all waypoints for routing
     **/
    func removeAllWaypoints() {
        self.waypoints = []
    }

    /**
     * is editing marker now?
     * @return BOOL
     **/
    func isEditingMarkerNow() -> Bool {
        return (self.editingMarker != nil) || (self.editingCoordinate != nil)
    }

    /**
     * request route
     * @param completionHandler completion handler
     **/
    func requestRoute(completionHandler: () -> Void) {
        let location = self.myLocation
        if location == nil { return }

        HMAGoogleMapClient.sharedInstance.getRoutes(
            origin: location!.coordinate,
            destinations: self.destinations,
            waypoints: self.waypoints,
            completionHandler: { [unowned self] (jsons) in
                    self.routeJSONs = jsons

                    completionHandler()

                    self.draw()
                }
        )
    }

    /**
     * update camera when routing has done
     **/
    func updateCameraWhenRoutingHasDone() {
        let startLocation = self.myLocation
        if startLocation == nil { return }
        if self.destinations.count == 0 { return }
        let end = self.destinations[0]

        let encodedPathes = self.encodedPathes()
        if encodedPathes.count == 0 { return }

        let path = GMSPath(fromEncodedPath: encodedPathes[0])
        var bounds = GMSCoordinateBounds(path: path)
        self.moveCamera(GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsetsMake(140.0, 40.0, 120.0, 80.0)))

        let startPoint = self.projection.pointForCoordinate(startLocation.coordinate)
        let endPoint = self.projection.pointForCoordinate(end)
        var angle = HMAMapMath.angle(pointA: startPoint, pointB: endPoint)
        angle += 90.0
        if angle > 360.0 { angle -= 360.0 }
        self.animateToBearing(angle)
    }

    /**
     * return routeDuration
     * @return String ex) "7 mins"
     **/
    func routeDuration() -> String {
        let jsons = self.routeJSONs
        if jsons == nil { return "" }

        var seconds = 0
        for var i = 0; i < jsons!.count; i++ {
            seconds += jsons![i].routeSeconds()
        }
        let hour = seconds / 3600
        let min = (seconds % 3600) / 60
        if hour > 0 { return "\(hour) hr \(min) min" }
        else if min > 0 { return "\(min) min" }
        return ""
    }

    /**
     * return endAddress
     * @return String ex) "711B Market Street, San Francisco, CA 94103, USA"
     **/
    func endAddress() -> String {
        let jsons = self.routeJSONs
        if jsons == nil { return "" }
        if jsons!.count == 0 { return "" }

        let json = jsons![jsons!.count - 1]
        let address = json.endAddress()
        return (address == nil) ? "" : address!
    }

//    /**
//     * check if map should update drawing
//     * @return Bool
//     **/
//    func shouldUpdateWhatMapDraws() -> Bool {
//        func update() {
//            let drawingPoints = [
//                CGPointMake(-self.frame.size.width*0.5, -self.frame.size.height*0.5),
//                CGPointMake(-self.frame.size.width*0.5, self.frame.size.height*1.5),
//                CGPointMake(self.frame.size.width*1.5, -self.frame.size.height*0.5),
//                CGPointMake(self.frame.size.width*1.5, self.frame.size.height*1.5),
//            ]
//            let drawingMin = self.minimumCoordinate(mapViewPoints: drawingPoints)
//            let drawingMax = self.maximumCoordinate(mapViewPoints: drawingPoints)
//            self.drawingRect = CGRectMake(
//                CGFloat(drawingMin.latitude),
//                CGFloat(drawingMin.longitude),
//                CGFloat(drawingMax.latitude-drawingMin.latitude),
//                CGFloat(drawingMax.longitude-drawingMin.longitude)
//            )
//            self.drawingZoom = self.camera.zoom
//        }
//
//        if self.drawingZoom == nil || self.drawingRect == nil {
//            update()
//            return false
//        }
//
//        if abs(self.drawingZoom! - self.camera.zoom) > 0.1 {
//            update()
//            return true
//        }
//
//        let cameraPoints = [
//            CGPointMake(0, 0),
//            CGPointMake(0, self.frame.size.height),
//            CGPointMake(self.frame.size.width, 0),
//            CGPointMake(self.frame.size.width, self.frame.size.height),
//        ]
//        let cameraMin = self.minimumCoordinate(mapViewPoints: cameraPoints)
//        let cameraMax = self.maximumCoordinate(mapViewPoints: cameraPoints)
//        var cameraRect = CGRectMake(
//            CGFloat(cameraMin.latitude),
//            CGFloat(cameraMin.longitude),
//            CGFloat(cameraMax.latitude-cameraMin.latitude),
//            CGFloat(cameraMax.longitude-cameraMin.longitude)
//        )
//
//        let contains = CGRectContainsRect(self.drawingRect!, cameraRect)
//        if !contains { update() }
//        return contains
//    }


    /// MARK: - private api

    /**
     * draw destinations
     **/
    private func drawDestinations() {
        for var i = 0; i < self.destinations.count; i++ {
            let destination = self.destinations[i]
            self.drawDestination(location: destination, index: i)
        }
    }

    /**
     * draw route
     **/
    private func drawRoute() {
        let encodedPathes = self.encodedPathes()

        for pathString in encodedPathes {
            let path = GMSPath(fromEncodedPath: pathString)
            var line = GMSPolyline(path: path)
            line.strokeWidth = 4.0
            line.tappable = false
            line.map = self
            line.zIndex = HMAGoogleMap.ZIndex.Route
            self.overlayManager.appendOverlay(line)
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
        marker.map = self
        self.overlayManager.appendOverlay(marker)
    }

    /**
     * draw destination marker
     * @param location location
     * @param index Int
     **/
    private func drawDestination(#location: CLLocationCoordinate2D, index: Int) {
        var marker = HMADestinationMarker(position: location, index: index)
        marker.map = self
        self.overlayManager.appendOverlay(marker)
    }

    /**
     * draw crimes
     **/
    private func drawCrimeMakers() {
        if self.crimeDatas.count == 0 { return }

        //var start = NSDate()

/*
        for crime in self.crimeDatas {
            self.drawCrimeMaker(crime: crime)
        }
*/
        var count = self.crimeDatas.count
        if count > HMAGoogleMap.MaxNumber.Crime { count = HMAGoogleMap.MaxNumber.Crime }
        for var i = 0; i < count; i++ {
            self.drawCrimeMaker(crime: self.crimeDatas[i])
        }

        //var end = NSDate()
        //var interval = end.timeIntervalSinceDate(start)
        //HMALOG("drawCrimeMakers: \(interval), count: \(self.crimeDatas.count)")
    }

    /**
     * draw crime marker
     * @param crime HMACrimeData
     **/
    private func drawCrimeMaker(#crime: HMACrimeData) {
        var marker = HMACrimeMarker(position: CLLocationCoordinate2DMake(crime.lat.doubleValue, crime.long.doubleValue), crime: crime)
        marker.map = self
        self.overlayManager.appendOverlay(marker)
    }

    /**
     * draw heat index heatmap
     **/
    private func drawHeatIndexHeatmap() {
        //var start = NSDate()
        // make heatmap
        var locations: [CLLocation] = []
        var weights: [NSNumber] = []
        let boost: Float = 1.0
        for var i = 0; i < self.heatIndexDatas.count; i++ {
            locations.append(CLLocation(latitude: self.heatIndexDatas[i].lat.doubleValue, longitude: heatIndexDatas[i].long.doubleValue))
            weights.append(NSNumber(double: self.sensorEvaluation.getHeatIndexWeight(humidity: heatIndexDatas[i].humidity.doubleValue, temperature: heatIndexDatas[i].temperature.doubleValue)))
        }
        let overlay = GMSGroundOverlay(
            position: self.projection.coordinateForPoint(CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)),
            icon: UIImage.heatIndexHeatmapImage(mapView: self, frame: self.frame/*CGRectMake(-self.frame.size.width*0.5, -self.frame.size.height*0.5, self.frame.size.width*2.0, self.frame.size.height*2.0)*/, locations: locations, weights: weights, boost: boost),
            zoomLevel: CGFloat(self.camera.zoom)
        )
        //var end = NSDate()
        //var interval = end.timeIntervalSinceDate(start)
        //HMALOG("Interval: \(interval)")

        overlay.bearing = self.camera.bearing
        overlay.map = self
        overlay.zIndex = HMAGoogleMap.ZIndex.HeatIndex
        self.overlayManager.appendOverlay(overlay)
    }

    /**
     * draw data visualization by wheel data and polyline
     **/
    private func drawWheelPolyline() {
        // draw line
        func drawPolyline(
            #map: HMAMapView,
            coordinateA: CLLocationCoordinate2D,
            coordinateB: CLLocationCoordinate2D,
            color: UIColor,
            zIndex: Int32
        ) {
/*
            var path = GMSMutablePath()
            path.addCoordinate(coordinateA)
            path.addCoordinate(coordinateB)
            var line = GMSPolyline(path: path)
*/
            //let polyline = Polyline(coordinates: [coordinateA, coordinateB,], levels: [0,1,2,3,])
            let polyline = Polyline(coordinates: [coordinateA, coordinateB,], levels: [16,])
            var line = GMSPolyline(path: GMSPath(fromEncodedPath: polyline.encodedPolyline))
            line.strokeColor = color
            line.strokeWidth = 4.0
            line.tappable = false
            line.map = map
            line.zIndex = zIndex
            self.overlayManager.appendOverlay(line)
        }
/*
        // RiderTorque
        for var i = 0; i < self.torqueDatas.count - 1; i++ {
            let locationA = CLLocation(latitude: self.torqueDatas[i].lat.doubleValue, longitude: self.torqueDatas[i].long.doubleValue)
            let locationB = CLLocation(latitude: self.torqueDatas[i+1].lat.doubleValue, longitude: self.torqueDatas[i+1].long.doubleValue)
            if HMAMapMath.miles(locationA: locationA, locationB: locationB) > HMAWheel.MaxDistanceForTorqueVisualization { continue }

            drawPolyline(
                map: self,
                locationA.coordinate,
                locationB.coordinate,
                self.wheelEvaluation.getRiderTorqueColor(torqueA: self.torqueDatas[i].value.doubleValue, torqueB: self.torqueDatas[i+1].value.doubleValue),
                self.wheelEvaluation.getRiderTorqueZIndex(torqueA: self.torqueDatas[i].value.doubleValue, torqueB: self.torqueDatas[i+1].value.doubleValue)
            )
        }
*/
        //var start = NSDate()
        // Acceleration
        for var i = 0; i < self.accelDatas.count - 1; i++ {
            let locationA = CLLocation(latitude: self.accelDatas[i].lat.doubleValue, longitude: self.accelDatas[i].long.doubleValue)
            let locationB = CLLocation(latitude: self.accelDatas[i+1].lat.doubleValue, longitude: self.accelDatas[i+1].long.doubleValue)
            if HMAMapMath.miles(locationA: locationA, locationB: locationB) > HMAWheel.MaxDistanceForAccelerationVisualization { continue }

            drawPolyline(
                map: self,
                locationA.coordinate,
                locationB.coordinate,
                self.wheelEvaluation.getMinusAccelerationColor(accelA: self.accelDatas[i].value.doubleValue, accelB: self.accelDatas[i+1].value.doubleValue),
                self.wheelEvaluation.getMinusAccelerationZIndex(accelA: self.accelDatas[i].value.doubleValue, accelB: self.accelDatas[i+1].value.doubleValue)
            )
        }
        //var end = NSDate()
        //var interval = end.timeIntervalSinceDate(start)
        //HMALOG("drawWheelPolyline: \(interval), count: \(self.accelDatas.count)")
    }

    /**
     * return encodedPath
     * @return [String]
     **/
    private func encodedPathes() -> [String] {
        // make pathes
        var pathes = [] as [String]
        let jsons = self.routeJSONs
        if jsons == nil { return pathes }

        for var i = 0; i < jsons!.count; i++ {
            let path = jsons![i].encodedPath()
            if path != nil { pathes.append(path!) }
        }

        return pathes
    }

    /**
     * return end location
     * @return [CLLocationCoordinate2D]
     **/
    private func endLocations() -> [CLLocationCoordinate2D] {
        var locations: [CLLocationCoordinate2D] = []
        let jsons = self.routeJSONs
        if jsons == nil { return locations }

        for var i = 0; i < jsons!.count; i++ {
            let location = jsons![i].endLocation()
            if location != nil { locations.append(location!) }
        }

        return locations
    }

}
