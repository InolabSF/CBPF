import WatchKit
import Foundation


/// MARK: - HMADetailInterfaceController
class HMADetailInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    /// MARK: - property
    @IBOutlet weak var landingGroup: WKInterfaceGroup!
    @IBOutlet weak var ratingLabel: WKInterfaceLabel!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!
    @IBOutlet weak var map: WKInterfaceMap!
    @IBOutlet weak var phoneButton: WKInterfaceButton!

    var sale: HMASale!
    var locationManager = CLLocationManager()


    /// MARK: - life cycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        self.sale = context as! HMASale
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }

    override func willActivate() {
        super.willActivate()

        // map
        self.map.setRegion(MKCoordinateRegionMake(self.sale.coordinate, MKCoordinateSpanMake(0.02, 0.02)))

        // design
        self.design()

        // core location
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
                break
            default:
                break
            }
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        /// remote notification
    }

    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        /// local notification
    }

    override func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
        /// glance
    }


    /// MARK: - private api
    private func design() {
        // destination
        self.map.addAnnotation(
            self.sale.coordinate,
            withPinColor: .Green
        )
        // rating label
        var rating = ""
        let maxRatingCount = 5
        let ratingCount = (self.sale.rating >= 0 && self.sale.rating <= maxRatingCount) ? self.sale.rating : 0
        for var i = 1; i <= maxRatingCount; i++ {
            rating += (i <= ratingCount) ? "★" : "☆"
        }
        self.ratingLabel.setText(rating)
        // title
        self.titleLabel.setText(self.sale.title)
        // description
        self.descriptionLabel.setText("\"" + self.sale.desc + "\"")
        // detail image
        if let data = NSData(contentsOfURL: self.sale.imageURL!) {
            self.landingGroup.setBackgroundImageData(data)
        }
        // phone number
        self.phoneButton.setTitle(self.sale.phoneNumber!)
    }

}


/// MARK: - CLLocationManagerDelegate
extension HMADetailInterfaceController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.map.removeAllAnnotations()
        // current location
        self.map.addAnnotation(
            CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude),
            withPinColor: .Red
        )
        // destination
        self.map.addAnnotation(
            self.sale.coordinate,
            withPinColor: .Green
        )
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {

    }

}
