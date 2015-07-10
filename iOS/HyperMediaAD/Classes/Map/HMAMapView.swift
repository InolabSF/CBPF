/// MARK: - HMAMapViewDelegate
protocol HMAMapViewDelegate {

    /**
     * called when next button touched up inside
     * @param mapView HMAMapView
     */
    func touchedUpInsideNextButton(#mapView: HMAMapView)

}


/// MARK: - HMAMapView
class HMAMapView: GMSMapView {

    /// MARK: - properties

    static let sharedInstance = HMAMapView()

    /// delegate
    var hmaDelegate: HMAMapViewDelegate?

    /// overlays
    private var overlays: [GMSOverlay] = []
    /// next button
    private var nextButton: BFPaperButton!
    /// setting button
    private var settingButton: HMASettingButton!

    /* ***** Destination ***** */
    /// search box
    private var searchBoxView: HMASearchBoxView!
    /// search result
    private var searchResultView: HMASearchResultView!

    /* ***** Route ***** */
    // tile layer
    private var tileLayer: GMSURLTileLayer?

    /// crime button
    private var crimeButton: HMACircleButton!
    /// heatindex button
    private var comfortButton: HMACircleButton!
    /// wheel button
    private var wheelButton: HMACircleButton!

    /// editing destination
    private var editingDestination: CLLocationCoordinate2D?
    /// destinations for routing
    var destinations: [CLLocationCoordinate2D] = []
    /// editing waypoint
    var editingWaypoint: CLLocationCoordinate2D?
    /// waypoints for routing
    var waypoints: [CLLocationCoordinate2D] = []
    /// route json
    private var routeJSONs: [JSON]?

    /* ***** Visualization ***** */
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


    /// MARK: - event listener

    func touchedUpInsideNextButton(button: UIButton) {
        if self.nextButton.alpha < 0.9 { return }
        if self.hmaDelegate != nil {
            self.hmaDelegate?.touchedUpInsideNextButton(mapView: self)
        }
    }


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
        //self.trafficEnabled = true

        // circle buttons
        let xOffset: CGFloat = 10.0
        let yOffset: CGFloat = 10.0
        var circleButtons: [HMACircleButton] = []
        let circleButtonImages = [UIImage(named: "button_crime")!, UIImage(named: "button_comfort")!, UIImage(named: "button_wheel")!]
        for var i = 0; i < circleButtonImages.count; i++ {
            let circleButtonNib = UINib(nibName: HMANSStringFromClass(HMACircleButton), bundle:nil)
            let circleButtonViews = circleButtonNib.instantiateWithOwner(nil, options: nil)
            let circleButtonView = circleButtonViews[0] as! HMACircleButton
            circleButtonView.frame = CGRectMake(
                self.frame.size.width - circleButtonView.frame.size.width - xOffset,
                self.frame.size.height - (circleButtonView.frame.size.height + yOffset) * CGFloat(i+2),
                circleButtonView.frame.size.width,
                circleButtonView.frame.size.height
            )
            circleButtonView.setImage(circleButtonImages[i])
            self.addSubview(circleButtonView)
            circleButtonView.delegate = self

            circleButtons.append(circleButtonView)
        }
        self.crimeButton = circleButtons[0]
        self.comfortButton = circleButtons[1]
        self.wheelButton = circleButtons[2]

        // next button
        self.nextButton = BFPaperButton(
            frame: CGRectMake(circleButtons[0].frame.size.width + xOffset * 2.0, circleButtons[0].frame.origin.y+(circleButtons[0].frame.size.height + yOffset), self.frame.size.width - (circleButtons[0].frame.size.width + xOffset * 2.0) * 2.0, circleButtons[0].frame.size.height),
           raised: false
        )
        self.nextButton.setTitle("Route", forState: .Normal)
        self.nextButton.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        self.nextButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.nextButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        self.nextButton.addTarget(self, action: "touchedUpInsideNextButton:", forControlEvents: .TouchUpInside)
        self.nextButton.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.nextButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.nextButton.layer.shadowOpacity = 0.4
        let rect = CGRectMake(self.nextButton.bounds.origin.x, self.nextButton.bounds.origin.y + 2, self.nextButton.bounds.size.width, self.nextButton.bounds.size.height)
        self.nextButton.layer.shadowPath = UIBezierPath(rect: rect).CGPath
        self.addSubview(self.nextButton)

        // setting button
        let settingButtonNib = UINib(nibName: HMANSStringFromClass(HMASettingButton), bundle:nil)
        let settingButtonViews = settingButtonNib.instantiateWithOwner(nil, options: nil)
        self.settingButton = settingButtonViews[0] as! HMASettingButton
        self.settingButton.delegate = self
        self.settingButton.frame = CGRectMake(xOffset, self.frame.size.height - (self.settingButton.frame.size.height + yOffset), self.settingButton.frame.size.width, self.settingButton.frame.size.height)
        self.addSubview(self.settingButton)

        // search result
        let searchResultNib = UINib(nibName: HMANSStringFromClass(HMASearchResultView), bundle:nil)
        let searchResultViews = searchResultNib.instantiateWithOwner(nil, options: nil)
        self.searchResultView = searchResultViews[0] as! HMASearchResultView
        self.searchResultView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        self.searchResultView.hidden = true
        self.searchResultView.delegate = self
        self.addSubview(self.searchResultView)
        self.searchResultView.design()

        // search box
        let searchBoxNib = UINib(nibName: HMANSStringFromClass(HMASearchBoxView), bundle:nil)
        let searchBoxViews = searchBoxNib.instantiateWithOwner(nil, options: nil)
        self.searchBoxView = searchBoxViews[0] as! HMASearchBoxView
        self.searchBoxView.delegate = self
        self.addSubview(self.searchBoxView)
        self.searchBoxView.design(parentView: self)
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

        // destination
        self.drawDestinations()

        // route
        if self.routeJSONs != nil {
            self.drawRoute()
        }
    }

    /**
     * set route jsons
     * @param jsons jsons
     **/
    func setRouteJSONs(jsons: [JSON]?) {
        self.routeJSONs = jsons
        //if jsons == nil { self.removeAllWaypoints() }
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
            self.searchBoxView.hidden = false
            self.crimeButton.hidden = true
            self.comfortButton.hidden = true
            self.wheelButton.hidden = true
            self.updateNextButton()
            self.nextButton.hidden = false

            self.shouldDrawCrimes = false
            self.shouldDrawComfort = false
            self.shouldDrawWheel = false
            self.crimeButton.setIsOn(false)
            self.comfortButton.setIsOn(false)
            self.wheelButton.setIsOn(false)
        }
        else if mode == HMAUserInterface.Mode.SetRoute {
            self.searchBoxView.hidden = true
            self.crimeButton.hidden = false
            self.comfortButton.hidden = false
            self.wheelButton.hidden = false
            self.nextButton.hidden = false

            self.shouldDrawCrimes = true
            self.shouldDrawComfort = true
            self.shouldDrawWheel = true
            self.crimeButton.setIsOn(true)
            self.comfortButton.setIsOn(true)
            self.wheelButton.setIsOn(true)
        }
        else if mode == HMAUserInterface.Mode.Cycle {
            self.searchBoxView.hidden = true
            self.crimeButton.hidden = false
            self.comfortButton.hidden = false
            self.wheelButton.hidden = false
            self.nextButton.hidden = false

            self.shouldDrawCrimes = false
            self.shouldDrawComfort = false
            self.shouldDrawWheel = false
            self.crimeButton.setIsOn(false)
            self.comfortButton.setIsOn(false)
            self.wheelButton.setIsOn(false)
        }

        // next button
        if mode == HMAUserInterface.Mode.SetDestinations {
            self.nextButton.setTitle("Route", forState: .Normal)
        }
        else if mode == HMAUserInterface.Mode.SetRoute {
            self.nextButton.setTitle("Start Cycling", forState: .Normal)
        }
        else if mode == HMAUserInterface.Mode.Cycle {
            self.nextButton.setTitle("End Cycling", forState: .Normal)
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
        self.destinations = []
    }

    /**
     * start Editing Destination
     **/
    func startEditingDestination(destination: CLLocationCoordinate2D) {
        self.editingDestination = destination
    }

    /**
     * delete Editing Destination
     **/
    func deleteEditingDestination() {
        var index = -1
        for var i = 0; i < self.destinations.count; i++ {
            let location1 = CLLocation(latitude: self.destinations[i].latitude, longitude: self.destinations[i].longitude)
            let location2 = CLLocation(latitude: self.editingDestination!.latitude, longitude: self.editingDestination!.longitude)
            let meter = location1.distanceFromLocation(location2)
            if meter > 10 { continue }
            index = i
            break
        }
        self.editingDestination = nil
        if index >= 0 {
            self.destinations.removeAtIndex(index)
        }
    }

    /**
     * start Dragging Destination
     * @param destination destination
     **/
    func startDraggingDestination(destination: CLLocationCoordinate2D) {
        self.editingDestination = destination
    }

    /**
     * end Dragging Destination
     * @param destination destination
     **/
    func endDraggingDestination(destination: CLLocationCoordinate2D) {
        var index = -1
        for var i = 0; i < self.destinations.count; i++ {
            let location1 = CLLocation(latitude: self.destinations[i].latitude, longitude: self.destinations[i].longitude)
            let location2 = CLLocation(latitude: self.editingDestination!.latitude, longitude: self.editingDestination!.longitude)
            let meter = location1.distanceFromLocation(location2)
            if meter > 10 { continue }
            index = i
            break
        }
        self.editingDestination = nil
        if index >= 0 {
            self.destinations[index] = destination
        }
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
     * start Editing Waypoint
     * @param waypoint waypoint
     **/
    func startEditingWaypoint(waypoint: CLLocationCoordinate2D) {
        self.editingWaypoint = waypoint
    }

    /**
     * delete Editing Waypoint
     * @param waypoint waypoint
     **/
    func deleteEditingWaypoint() {
        var index = -1
        for var i = 0; i < self.waypoints.count; i++ {
            let location1 = CLLocation(latitude: self.waypoints[i].latitude, longitude: self.waypoints[i].longitude)
            let location2 = CLLocation(latitude: self.editingWaypoint!.latitude, longitude: self.editingWaypoint!.longitude)
            let meter = location1.distanceFromLocation(location2)
            if meter > 10 { continue }
            index = i
            break
        }
        self.editingWaypoint = nil
        if index >= 0 {
            self.waypoints.removeAtIndex(index)
        }
    }

    /**
     * start Dragging Waypoint
     * @param waypoint waypoint
     **/
    func startDraggingWaypoint(waypoint: CLLocationCoordinate2D) {
        self.editingWaypoint = waypoint
    }

    /**
     * end Dragging Waypoint
     * @param waypoint waypoint
     **/
    func endDraggingWaypoint(waypoint: CLLocationCoordinate2D) {
        var index = -1
        for var i = 0; i < self.waypoints.count; i++ {
            let location1 = CLLocation(latitude: self.waypoints[i].latitude, longitude: self.waypoints[i].longitude)
            let location2 = CLLocation(latitude: self.editingWaypoint!.latitude, longitude: self.editingWaypoint!.longitude)
            let meter = location1.distanceFromLocation(location2)
            if meter > 10 { continue }
            index = i
            break
        }
        self.editingWaypoint = nil
        if index >= 0 {
            self.waypoints[index] = waypoint
        }
    }

    /**
     * is dragging now?
     * @return BOOL
     **/
    func isDraggingNow() -> Bool {
        return (self.editingWaypoint != nil) || (self.editingDestination != nil)
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
                    self.setRouteJSONs(jsons)

                    completionHandler()
                    // update camera position
/*
                    var pathes: [GMSPath] = []
                    let encodedPathes = self.encodedPathes()
                    for pathString in encodedPathes {
                        let path = GMSPath(fromEncodedPath: pathString)
                        pathes.append(path)
                    }
                    let bounds = self.encodedBounds(pathes: pathes)
                    if bounds != nil {
                        self.moveCamera(GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsetsMake(80.0, 40.0, self.nextButton.frame.size.height*1.5, self.crimeButton.frame.size.width*1.5)))
                    }
*/
                    self.draw()
                }
        )
    }

    /**
     * update next button
     **/
    func updateNextButton() {
        self.nextButton.alpha = (self.destinations.count > 0) ? 1.0 : 0.35
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
        self.moveCamera(GMSCameraUpdate.fitBounds(bounds, withEdgeInsets: UIEdgeInsetsMake(80.0, 40.0, self.nextButton.frame.size.height*1.5, self.crimeButton.frame.size.width*1.5)))

        let startPoint = self.projection.pointForCoordinate(startLocation.coordinate)
        let endPoint = self.projection.pointForCoordinate(end)
        var angle = HMAMapMath.angle(pointA: startPoint, pointB: endPoint)
        angle += 90.0
        if angle > 360.0 { angle -= 360.0 }
        self.animateToBearing(angle)
        //self.animateToViewingAngle(angle)
    }


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
            self.overlays.append(line)
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
        self.overlays.append(marker)
    }

    /**
     * draw destination marker
     * @param location location
     * @param index Int
     **/
    private func drawDestination(#location: CLLocationCoordinate2D, index: Int) {
        var marker = HMADestinationMarker(position: location, index: index)
        marker.map = self
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
        var marker = HMACrimeMarker(position: CLLocationCoordinate2DMake(crime.lat.doubleValue, crime.long.doubleValue), crime: crime)
        marker.map = self
        self.overlays.append(marker)
    }

    /**
     * draw yelp
     **/
    private func drawYelp() {
        let yelpDatas = HMAYelpClient.sharedInstance.yelpDatas
        if yelpDatas == nil { return }

        for yelpData in yelpDatas! {
            var marker = HMAYelpMaker(position: yelpData.coordinate, yelpData: yelpData)
            marker.map = self
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
            line.strokeWidth = 4.0
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
        let jsons = self.routeJSONs
        if jsons == nil { return pathes }

        for var i = 0; i < jsons!.count; i++ {
            let json = jsons![i]
            let routes = json["routes"].arrayValue
            for route in routes {
                let overviewPolyline = route["overview_polyline"].dictionaryValue
                let path = overviewPolyline["points"]!.stringValue
                pathes.append(path)
            }
        }

        return pathes
    }

    /**
     * return bounds from routeJSONs
     * @param pathes [GMSPath]
     * @return GMSCoordinateBounds or nil
     **/
/*
    private func encodedBounds(#pathes: [GMSPath]) -> GMSCoordinateBounds? {
        var boundses: [GMSCoordinateBounds] = []
        for path in pathes {
            boundses.append(GMSCoordinateBounds(path: path))
        }
        if boundses.count == 0 { return nil }

        var bounds = boundses[0]
        for var i = 1; i < boundses.count; i++ {
            bounds = bounds.includingBounds(boundses[i])
        }

        return bounds
    }
*/

    /**
     * return end location
     * @return [CLLocationCoordinate2D]
     **/
    private func endLocations() -> [CLLocationCoordinate2D] {
        var locations: [CLLocationCoordinate2D] = []
        let jsons = self.routeJSONs
        if jsons == nil { return locations }

        for var i = 0; i < jsons!.count; i++ {
            let json = jsons![i]
            let routes = json["routes"].arrayValue
            for route in routes {
                let legs = route["legs"].arrayValue
                for leg in legs {
                    if let locationDictionary = leg["end_location"].dictionary {
                        locations.append(CLLocationCoordinate2D(latitude: locationDictionary["lat"]!.doubleValue, longitude: locationDictionary["lng"]!.doubleValue))
                    }
                }
            }
        }

        return locations
    }

}


/// MARK: - HMASettingButtonDelegate
extension HMAMapView: HMASettingButtonDelegate {

    func settingButton(settingButton: HMASettingButton) {
        HMADrawerController.sharedInstance.setDrawerState(.Opened, animated: true)
    }

}


/// MARK: - HMASearchBoxViewDelegate
extension HMAMapView: HMASearchBoxViewDelegate {

    func searchBoxWasActive(#searchBoxView: HMASearchBoxView) {
        self.searchResultView.hidden = false
    }

    func searchBoxWasInactive(#searchBoxView: HMASearchBoxView) {
        self.searchResultView.hidden = true
    }

    func searchDidFinish(#searchBoxView: HMASearchBoxView, destinations: [HMADestination]) {
        self.searchResultView.updateDestinations(destinations)
    }

    func clearButtonTouchedUpInside(#searchBoxView: HMASearchBoxView) {
        if self.searchBoxView.isActive { return }
        self.draw()
    }

    func geoLocationSearchDidFinish(#searchBoxView: HMASearchBoxView, coordinate: CLLocationCoordinate2D) {
        self.appendDestination(coordinate)
        self.updateWhatMapDraws()
        self.draw()
        self.updateNextButton()
    }

}


/// MARK: - HMASearchResultViewDelegate
extension HMAMapView: HMASearchResultViewDelegate {

    func didSelectRow(#searchResultView: HMASearchResultView, selectedDestination: HMADestination) {
        self.searchBoxView.endSearch()
        self.searchBoxView.setSearchText(selectedDestination.desc)

        let location = self.myLocation
        if location == nil { return }
        self.searchBoxView.startSearchGeoLocation(coordinate: location!.coordinate)
    }

}


/// MARK: - HMACircleButtonDelegate
extension HMAMapView: HMACircleButtonDelegate {

    func circleButton(circleButton: HMACircleButton, wasOn: Bool) {
        if circleButton == self.crimeButton {
            self.shouldDrawCrimes = wasOn
            if wasOn { HMACrimeData.requestToGetCrimeData() }
        }
        else if circleButton == self.comfortButton {
            self.shouldDrawComfort = wasOn
            if wasOn {
                HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Humidity)
                HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Temperature)
            }
        }
        else if circleButton == self.wheelButton {
            self.shouldDrawWheel = wasOn
            if wasOn {
                HMAWheelData.requestToGetWheelData(dataType: HMAWheel.DataType.RiderTorque, max: nil, min: HMAWheel.Min.RiderTorque)
                HMAWheelData.requestToGetWheelData(dataType: HMAWheel.DataType.Acceleration, max: HMAWheel.Max.Acceleration, min: nil)
            }
        }

        self.updateWhatMapDraws()
        self.draw()
    }

}
