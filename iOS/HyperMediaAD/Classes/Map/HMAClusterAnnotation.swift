import CoreLocation


/// MARK: - HMAClusterAnnotation
class HMAClusterAnnotation: RMAnnotation {

    /// MARK: - property
    var sensorValue: Double!


    /// MARK: - initialization
    init(mapView: RMMapView, coordinate: CLLocationCoordinate2D, title: String, sensorValue: Double) {
        super.init(mapView: mapView, coordinate: coordinate, andTitle: title)
        self.sensorValue = sensorValue
    }


}
