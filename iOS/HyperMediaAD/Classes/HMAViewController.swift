import UIKit
import CoreLocation


/// MARK: - HMAViewController
class HMAViewController: UIViewController, CLLocationManagerDelegate, RMMapViewDelegate {

    /// MARK: - property

    /// CLLocationManager
    var locationManager: CLLocationManager!
    /// mapview
    var mapView: RMMapView!


    /// MARK: - destruction
    deinit {
        self.mapView.removeFromSuperview()
        self.mapView = nil
    }


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // mapview
        self.mapView = RMMapView(frame: self.view.bounds, andTilesource: RMMapboxSource(mapID:"kenzan8000.m4484c13"))
        self.mapView.zoom = 14
        self.mapView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.mapView.clusteringEnabled = true
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self;
        self.view.addSubview(self.mapView)

        // core location
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 300
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


/// MARK: - CLLocationManagerDelegate
extension HMAViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.mapView.centerCoordinate = newLocation.coordinate

        let annotation = RMPointAnnotation(mapView: self.mapView, coordinate: self.mapView.centerCoordinate, andTitle: "Your Location")
        self.mapView.addAnnotation(annotation)

        HMASensorClient.getSensorData(
            sensorType: 1,
            coordinate: newLocation.coordinate,
            completionHandler: { [unowned self] (json) in
                if let sensorDatas = json["sensor_datas"].array {
                    for sensorData in sensorDatas {
                        let tempatureAnnotation = HMAClusterAnnotation(
                            mapView: self.mapView,
                            coordinate: CLLocationCoordinate2DMake(sensorData["lat"].double!, sensorData["long"].double!),
                            title: "",
                            sensorValue: sensorData["value"].double!
                        )
                        self.mapView.addAnnotation(tempatureAnnotation)
                    }
                }
            }
        )
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    }

}


/// MARK: - RMMapViewDelegate
extension HMAViewController: RMMapViewDelegate {
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer? {
        if !(annotation.isKindOfClass(HMAClusterAnnotation)) { return nil }

        let clusterAnnotation = (annotation as! HMAClusterAnnotation)
        let clusterValue = clusterAnnotation.sensorValue

        var layer = RMMarker(UIImage: UIImage(named: "map_circle"))
        layer.opacity = 0.75;
        layer.bounds = CGRectMake(0, 0, CGFloat(clusterValue), CGFloat(clusterValue))
        layer.textForegroundColor = UIColor.whiteColor()
        layer.changeLabelUsingText(String(format: "%.0fF", clusterValue))

        return layer
    }

    func mapView(mapView: RMMapView, didUpdateUserLocation userLocation: RMUserLocation) {
        HMALOG("updated")
    }
}
