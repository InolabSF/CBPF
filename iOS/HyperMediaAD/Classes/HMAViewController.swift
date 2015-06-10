import UIKit
import CoreLocation


/// MARK: - HMAViewController
class HMAViewController: UIViewController, CLLocationManagerDelegate {

    /// MARK: - property
    @IBOutlet weak var testButton: UIButton!
    var destinationString: String = ""

    var mapView: HMAMapView!
    var searchBoxView: HMASearchBoxView!
    var searchResultView: HMASearchResultView!
    var horizontalTableView: HMAHorizontalTableView!
    var locationManager: CLLocationManager!


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.doSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /// MARK: - event listener

    /**
     * called when touched button
     * @param button UIButton
     **/
    @IBAction func touchedUpInside(#button: UIButton) {
        self.mapView.removeAllWaypoints()
        self.requestDirectoin()
    }


    /// MARK: - private api

    /**
     * do settings
     **/
    private func doSettings() {
        // google map view
        self.mapView = HMAMapView.sharedInstance
        self.mapView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.mapView.myLocationEnabled = true
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)

        // search result
        let searchResultNib = UINib(nibName: HMANSStringFromClass(HMASearchResultView), bundle:nil)
        let searchResultViews = searchResultNib.instantiateWithOwner(nil, options: nil)
        self.searchResultView = searchResultViews[0] as! HMASearchResultView
        self.searchResultView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        self.searchResultView.hidden = true
        self.searchResultView.delegate = self
        self.view.addSubview(self.searchResultView)
        self.searchResultView.design()

        // search box
        let searchBoxNib = UINib(nibName: HMANSStringFromClass(HMASearchBoxView), bundle:nil)
        let searchBoxViews = searchBoxNib.instantiateWithOwner(nil, options: nil)
        self.searchBoxView = searchBoxViews[0] as! HMASearchBoxView
        self.searchBoxView.delegate = self
        self.view.addSubview(self.searchBoxView)
        self.searchBoxView.design(parentView: self.view)

        // horizontal table view
        let horizontalTableViewNib = UINib(nibName: HMANSStringFromClass(HMAHorizontalTableView), bundle:nil)
        let horizontalTableViews = horizontalTableViewNib.instantiateWithOwner(nil, options: nil)
        self.horizontalTableView = horizontalTableViews[0] as! HMAHorizontalTableView
        self.horizontalTableView.frame = CGRectMake(0, self.view.frame.size.height-self.horizontalTableView.frame.size.height, self.view.frame.size.width, self.horizontalTableView.frame.size.height)
        self.view.addSubview(self.horizontalTableView)
        self.horizontalTableView.doSettings()
        self.horizontalTableView.delegate = self

        // location manager
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 300
        self.locationManager.startUpdatingLocation()

        self.view.bringSubviewToFront(self.horizontalTableView)
        self.view.bringSubviewToFront(self.searchResultView)
        self.view.bringSubviewToFront(self.searchBoxView)
        self.view.bringSubviewToFront(self.testButton)
    }

    /**
     * request dirction API and render direction
     */
    private func requestDirectoin() {
        if self.destinationString == "" { return }

        HMAGoogleMapClient.sharedInstance.cancelGetRoute()

        // google map direction API
        let location = self.mapView.myLocation
        if location == nil { return }
        let coordinate = location.coordinate
        HMAGoogleMapClient.sharedInstance.getRoute(
            queries: [ "origin" : "\(coordinate.latitude),\(coordinate.longitude)", "destination" : self.destinationString, ],
            completionHandler: { [unowned self] (json) in
                self.mapView.setRouteJSON(json)
                self.mapView.draw()
            }
        )
    }
}


/// MARK: - CLLocationManagerDelegate
extension HMAViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        let location = self.mapView.myLocation
        if location == nil { return }
        self.mapView.camera = GMSCameraPosition.cameraWithLatitude(
            location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: HMAGoogleMap.Zoom
        )
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    }

}


/// MARK: - GMSMapViewDelegate
extension HMAViewController: GMSMapViewDelegate {

    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.mapView.appendWaypoint(coordinate)
        self.requestDirectoin()
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        return true
    }

    func mapView(mapView: GMSMapView,  didBeginDraggingMarker marker: GMSMarker) {
        self.mapView.startMovingWaypoint(marker.position)
    }

    func mapView(mapView: GMSMapView,  didEndDraggingMarker marker: GMSMarker) {
        self.mapView.endMovingWaypoint(marker.position)
        self.requestDirectoin()
    }

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        let crimes = HMACrimeData.fetch(minimumCoordinate: self.mapView.minimumCoordinate(), maximumCoordinate: self.mapView.maximumCoordinate())
        if crimes.count > 0 { self.mapView.setCrimes(crimes) }
        self.mapView.draw()
    }

    func mapView(mapView: GMSMapView,  didDragMarker marker:GMSMarker) {
    }

}


/// MARK: - HMASearchBoxViewDelegate
extension HMAViewController: HMASearchBoxViewDelegate {

    func searchBoxWasActive(#searchBoxView: HMASearchBoxView) {
        self.searchResultView.hidden = false
    }

    func searchBoxWasInactive(#searchBoxView: HMASearchBoxView) {
        self.searchResultView.hidden = true
        self.searchBoxView.setSearchText(self.destinationString)
    }

    func searchDidFinish(#searchBoxView: HMASearchBoxView, destinations: [HMADestination]) {
        self.searchResultView.updateDestinations(destinations)
    }

    func clearButtonTouchedUpInside(#searchBoxView: HMASearchBoxView) {
        if self.searchBoxView.isActive { return }
        self.mapView.setRouteJSON(nil)
        self.destinationString = ""
        self.mapView.draw()
    }

}


/// MARK: - HMASearchResultViewDelegate
extension HMAViewController: HMASearchResultViewDelegate {

    func didSelectRow(#searchResultView: HMASearchResultView, selectedDestination: HMADestination) {
        self.searchBoxView.endSearch()
        self.searchBoxView.setSearchText(selectedDestination.desc)
        if self.destinationString == selectedDestination.desc { return }
        self.destinationString = selectedDestination.desc
        self.mapView.removeAllWaypoints()
        self.requestDirectoin()
    }

}


/// MARK: - HMAHorizontalTableViewDelegate
extension HMAViewController: HMAHorizontalTableViewDelegate {

    func tableView(tableView: HMAHorizontalTableView, indexPath: NSIndexPath, wasOn: Bool) {
        let markerType = tableView.dataSource[indexPath.row].markerType
        self.mapView.setCrimeMarkerType(markerType)

        let location = self.mapView.myLocation
        let on = wasOn && (location != nil)
        let crimes = HMACrimeData.fetch(minimumCoordinate: self.mapView.minimumCoordinate(), maximumCoordinate: self.mapView.maximumCoordinate())
        self.mapView.setCrimes(on ? crimes : nil)

        self.mapView.draw()
    }

}

///// MARK: - HMAViewController
//class HMAViewController: UIViewController, CLLocationManagerDelegate, RMMapViewDelegate {
//
//    /// MARK: - property
//
//    /// CLLocationManager
//    var locationManager: CLLocationManager!
////    /// mapview
////    var mapView: HMAMapView!
//
//    /// test button
//    @IBOutlet var testButton: UIButton!
//    /// test label
//    @IBOutlet var testLabel: UILabel!
//
//
//    /// MARK: - destruction
//    deinit {
////        self.mapView.removeFromSuperview()
////        self.mapView = nil
//    }
//
//
//    /// MARK: - life cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // mapview
//        self.mapView = HMAMapView(frame: self.view.bounds, andTilesource: RMMapboxSource(mapID:HMAMapBox.MapID))
//
//        self.mapView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
//        self.mapView.clusteringEnabled = true
//        self.mapView.showsUserLocation = true
//        self.mapView.delegate = self;
//        self.view.addSubview(self.mapView)
//        //self.mapView.zoom = 15
//        self.mapView.setMetersPerPixel(14.0,  animated: false)
//
//        // core location
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.distanceFilter = 300
//        self.locationManager.startUpdatingLocation()
//
//        // test
//        self.view.bringSubviewToFront(self.testButton)
//        self.view.bringSubviewToFront(self.testLabel)
///*
//        // display comfort evaluation graph
//        let comfort = HMAComfort()
//        let graphs = [ comfort.heatIndexGraphView(), comfort.pm25GraphView(), comfort.soundLevelGraphView(), ]
//        var offsetY: CGFloat = 20.0
//        for var i = 0; i < graphs.count; i++ {
//            let graph = graphs[i]
//            graph.frame = CGRectMake(0, offsetY, graph.frame.size.width, graph.frame.size.height)
//            self.view.addSubview(graph)
//            offsetY += graph.frame.size.height
//        }
//*/
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//
//
//    /// MARK: - event listener
//
//    /**
//     * called when touched button
//     * @param button UIButton
//     **/
//    @IBAction func touchedUpInside(#button: UIButton) {
///*
//        // route
//        let userCoordinate = self.mapView.userLocation.location.coordinate
//        HMAGoogleMapClient.sharedInstance.removeAllWaypoints()
//        HMAGoogleMapClient.sharedInstance.getRoute(
//            queries: [ "origin" : "\(userCoordinate.latitude),\(userCoordinate.longitude)", "destination" : "37.7932,-122.4145", ],
//            completionHandler: { [unowned self] (json) in
//                self.mapView.setRouteFromGoogleMapAPIDirections(json: json)
//            }
//        )
//*/
///*
//        // get sensor data from CBPF server
//        HMASensorClient.sharedInstance.getSensorData(
//            radius: 12.5,
//            sensorType: HMASensor.SensorType.Noise,
//            coordinate: self.mapView.userLocation.location.coordinate,
//            completionHandler: { [unowned self] (json) in
//                // draw map
//                self.mapView.setNoiseAnnotation(json: json)
//            }
//        )
////HMASensor.SensorType.Humidity
////HMASensor.SensorType.Pm25
////HMASensor.SensorType.Temperature
//*/
//        // get crime data from CBPF server
//        HMACrimeClient.sharedInstance.cancelGetCrime()
//        HMACrimeClient.sharedInstance.getCrime(
//            radius: 12.5,
//        coordinate: CLLocationCoordinate2DMake(37.7932, -122.4145),
// completionHandler: { [unowned self] (json) in
//                self.mapView.setCrimeAnnotation(json: json)
//                //let crimeDatas = json["crime_datas"].arrayValue
//                //self.testLabel.text = "Number of crime is \(crimeDatas.count) (2015/1~4)."
//            }
//        )
//    }
//
//}
//
//
///// MARK: - CLLocationManagerDelegate
//extension HMAViewController: CLLocationManagerDelegate {
//
//    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
//        self.mapView.centerCoordinate = newLocation.coordinate
//    }
//
//    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
//    }
//
//}
//
//
///// MARK: - RMMapViewDelegate
//extension HMAViewController: RMMapViewDelegate {
//    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer? {
//        return self.mapView.getLayer(annotation: annotation)
//    }
//
//    func mapView(mapView: RMMapView, didUpdateUserLocation userLocation: RMUserLocation) {
//    }
//
//    func singleTapOnMap(map: RMMapView, at point: CGPoint) {
//        if self.mapView.hasKindOfAnnotationClass(HMARouteAnnotation) {
//            let userCoordinate = self.mapView.userLocation.location.coordinate
//            let coordinate = self.mapView.pixelToCoordinate(point)
//
//            HMAGoogleMapClient.sharedInstance.appendWaypoint(coordinate)
//            HMAGoogleMapClient.sharedInstance.getRoute(
//                queries: [ "origin" : "\(userCoordinate.latitude),\(userCoordinate.longitude)", "destination" : "37.7932,-122.4145", ],
//                completionHandler: { [unowned self] (json) in
//                    self.mapView.setRouteFromGoogleMapAPIDirections(json: json)
//                }
//            )
//
//            //HMALOG("latitude: \(coordinate.latitude) longitude: \(coordinate.longitude)")
//        }
//    }
//
//}
///*
//        let sensorDatas = HMASensorData.fetch(lat: NSNumber(float: 37.766817), long: NSNumber(float: -122.420791))
//        for sensorData in sensorDatas {
//            HMALOG("\(sensorData)")
//        }
//*/
///*
//        // post WheelData
//        HMAWheelClient.postWheelData(
//            wheelDatas: [
//            	"wheel_datas": [
//                 [
//                 	"data_type": 9,
//                 	"lat": 37.76681832250885,
//                 	"long": -122.4207906162038,
//                 	"user_id": 1,
//                 	"timestamp": "2015-05-07T01:25:39.738Z",
//                 	"value": 13.555334
//                 	],
//                 [
//                 	"data_type": 9,
//                 	"lat": 37.76681832250885,
//                 	"long": -122.4207906162038,
//                 	"user_id": 1,
//                 	"timestamp": "2015-05-07T01:25:39.738Z",
//                 	"value": 13.555334
//                 	],
//                 [
//                 	"data_type": 9,
//                 	"lat": 37.76681832250885,
//                 	"long": -122.4207906162038,
//                 	"user_id": 1,
//                 	"timestamp": "2015-05-07T01:25:39.738Z",
//                 	"value": 13.555334
//                 	],
//                 [
//                 	"data_type": 9,
//                 	"lat": 37.76681832250885,
//                 	"long": -122.4207906162038,
//                 	"user_id": 1,
//                 	"timestamp": "2015-05-07T01:25:39.738Z",
//                 	"value": 13.555334
//                 	]
//            	]
//            ],
//            completionHandler: { [unowned self] (json) in
//                HMALOG("\(json)")
//            }
//        )
//*/
//
