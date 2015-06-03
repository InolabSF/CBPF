import UIKit
import CoreLocation


/// MARK: - HMAViewController
class HMAViewController: UIViewController, CLLocationManagerDelegate, RMMapViewDelegate {

    /// MARK: - property

    /// CLLocationManager
    var locationManager: CLLocationManager!
    /// mapview
    var mapView: HMAMapView!

    /// test button
    @IBOutlet var testButton: UIButton!


    /// MARK: - destruction
    deinit {
        self.mapView.removeFromSuperview()
        self.mapView = nil
    }


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // mapview
        self.mapView = HMAMapView(frame: self.view.bounds, andTilesource: RMMapboxSource(mapID:HMAMapBox.MapID))

        self.mapView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.mapView.clusteringEnabled = true
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self;
        self.view.addSubview(self.mapView)
        //self.mapView.zoom = 15
        self.mapView.setMetersPerPixel(14.0,  animated: false)

        // core location
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 300
        self.locationManager.startUpdatingLocation()

        // test
        self.view.bringSubviewToFront(self.testButton)

        let comfort = HMAComfort()
        var heatIndexGraphView = comfort.heatIndexGraphView()
        heatIndexGraphView.frame = CGRectMake(0, 20, heatIndexGraphView.frame.size.width, heatIndexGraphView.frame.size.height)
        self.view.addSubview(heatIndexGraphView)
        var soundLevelGraphView = comfort.soundLevelGraphView()
        soundLevelGraphView.frame = CGRectMake(0, 20+heatIndexGraphView.frame.size.height, soundLevelGraphView.frame.size.width, soundLevelGraphView.frame.size.height)
        self.view.addSubview(soundLevelGraphView)
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

        // route
        let userCoordinate = self.mapView.userLocation.location.coordinate
        HMAGoogleMapClient.sharedInstance.removeAllWaypoints()
        HMAGoogleMapClient.sharedInstance.getRoute(
            queries: [ "origin" : "\(userCoordinate.latitude),\(userCoordinate.longitude)", "destination" : "37.7932,-122.4145", ],
            completionHandler: { [unowned self] (json) in
                self.mapView.setRouteFromGoogleMapAPIDirections(json: json)
            }
        )
/*
        // get sensor data from CBPF server
        HMASensorClient.getSensorData(
            sensorType: 1,
            coordinate: self.mapView.userLocation.location.coordinate,//newLocation.coordinate,
            completionHandler: { [unowned self] (json) in
                // draw map
                self.mapView.setTempatureAnnotation(json: json)
                // store core data
                //HMASensorData.save(json: json)
            }
        )
*/

    }


}


/// MARK: - CLLocationManagerDelegate
extension HMAViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.mapView.centerCoordinate = newLocation.coordinate
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    }

}


/// MARK: - RMMapViewDelegate
extension HMAViewController: RMMapViewDelegate {
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer? {
        return self.mapView.getLayer(annotation: annotation)
    }

    func mapView(mapView: RMMapView, didUpdateUserLocation userLocation: RMUserLocation) {
    }

    func singleTapOnMap(map: RMMapView, at point: CGPoint) {
        if self.mapView.hasKindOfAnnotationClass(HMARouteAnnotation) {
            let userCoordinate = self.mapView.userLocation.location.coordinate
            let coordinate = self.mapView.pixelToCoordinate(point)

            HMAGoogleMapClient.sharedInstance.appendWaypoint(coordinate)
            HMAGoogleMapClient.sharedInstance.getRoute(
                queries: [ "origin" : "\(userCoordinate.latitude),\(userCoordinate.longitude)", "destination" : "37.7932,-122.4145", ],
                completionHandler: { [unowned self] (json) in
                    self.mapView.setRouteFromGoogleMapAPIDirections(json: json)
                }
            )

            //HMALOG("latitude: \(coordinate.latitude) longitude: \(coordinate.longitude)")
        }
    }

}
/*
        let sensorDatas = HMASensorData.fetch(lat: NSNumber(float: 37.766817), long: NSNumber(float: -122.420791))
        for sensorData in sensorDatas {
            HMALOG("\(sensorData)")
        }
*/
/*
        // post WheelData
        HMAWheelClient.postWheelData(
            wheelDatas: [
            	"wheel_datas": [
                 [
                 	"data_type": 9,
                 	"lat": 37.76681832250885,
                 	"long": -122.4207906162038,
                 	"user_id": 1,
                 	"timestamp": "2015-05-07T01:25:39.738Z",
                 	"value": 13.555334
                 	],
                 [
                 	"data_type": 9,
                 	"lat": 37.76681832250885,
                 	"long": -122.4207906162038,
                 	"user_id": 1,
                 	"timestamp": "2015-05-07T01:25:39.738Z",
                 	"value": 13.555334
                 	],
                 [
                 	"data_type": 9,
                 	"lat": 37.76681832250885,
                 	"long": -122.4207906162038,
                 	"user_id": 1,
                 	"timestamp": "2015-05-07T01:25:39.738Z",
                 	"value": 13.555334
                 	],
                 [
                 	"data_type": 9,
                 	"lat": 37.76681832250885,
                 	"long": -122.4207906162038,
                 	"user_id": 1,
                 	"timestamp": "2015-05-07T01:25:39.738Z",
                 	"value": 13.555334
                 	]
            	]
            ],
            completionHandler: { [unowned self] (json) in
                HMALOG("\(json)")
            }
        )
*/

