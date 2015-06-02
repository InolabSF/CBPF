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
/*
        let chartView = self.chart()
        self.view.addSubview(chartView)
        self.view.bringSubviewToFront(chartView)
        let chartView2 = self.chart2()
        self.view.addSubview(chartView2)
        self.view.bringSubviewToFront(chartView2)
*/
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


    /// MARK: - private api
/*
    private func chart() -> FSLineChart {
        //
        var discomfortIndexSplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Cold), 1.0)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Chille), 0.6)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.NotChille), 0.2)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Comfort), 0.0)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.NotWarm), 0.2)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Warm), 0.5)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Hot), 0.7)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Boiling), 1.0)),
        ])

        var chartData: [CGFloat] = []
        let min = CGFloat(HMADiscomfortIndex.Cold)
        let max = CGFloat(HMADiscomfortIndex.Boiling)
        for var x = min; x <= max; x += 1.0 {
            var y = discomfortIndexSplineCurve.interpolate(x)
            if y < 0 { y = 0 }
            if y > 1.0 { y = 1.0 }
            chartData.append(y)
        }
        let lineChart = FSLineChart(frame: CGRectMake(20, 60, UIScreen.mainScreen().bounds.size.width - 40, 166))
        lineChart.verticalGridStep = 5
        lineChart.horizontalGridStep = 9
        lineChart.labelForIndex = { (item) in
            return "\(item)"
        }
        lineChart.labelForValue = { (value) in
            return "\(value)"
        }
        lineChart.setChartData(chartData)
        return lineChart
    }

    private func chart2() -> FSLineChart {
        //
        var soundLevelSplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level1), 0.0)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level2), 0.05)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level3), 0.1)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level4), 0.2)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level5), 0.3)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level6), 0.5)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level7), 0.7)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level8), 1.0)),
        ])
        var chartData: [CGFloat] = []
        let min = CGFloat(HMANoise.Level1)
        let max = CGFloat(HMANoise.Level8)
        for var x = min; x <= max; x += 1.0 {
            var y = soundLevelSplineCurve.interpolate(x)
            if y < 0 { y = 0 }
            if y > 1.0 { y = 1.0 }
            chartData.append(y)
        }
        let lineChart = FSLineChart(frame: CGRectMake(20, 60+166+40, UIScreen.mainScreen().bounds.size.width - 40, 166))
        lineChart.verticalGridStep = 5
        lineChart.horizontalGridStep = 9
        lineChart.labelForIndex = { (item) in
            return "\(item)"
        }
        lineChart.labelForValue = { (value) in
            return "\(value)"
        }
        lineChart.setChartData(chartData)
        return lineChart
    }
*/
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

