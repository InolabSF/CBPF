//import CoreLocation
//
//
///// MARK: - HMARouteAnnotation
//class HMARouteAnnotation: RMAnnotation {
//
//    /// MARK: - property
//    var locations: [CLLocation]!
//
//
//    /// MARK: - initialization
//    init(mapView: RMMapView, coordinate: CLLocationCoordinate2D, title: String, locations: [CLLocation]) {
//        super.init(mapView: mapView, coordinate: coordinate, andTitle: title)
//        self.locations = locations
//    }
//
//
//    /// MARK: - public api
//
//    /**
//     * get map layer to draw route
//     * @param mapView mapbox's mapView
//     * @return layer
//     */
//    func getLayer(#mapView: RMMapView) -> RMMapLayer? {
//        var shape = RMShape(view: mapView)
//        shape.lineColor = UIColor(red: 0.224, green: 0.671, blue: 0.780, alpha: 1.000)
//        shape.lineWidth = 4.0;
//        for location in self.locations {
//            shape.addLineToCoordinate(location.coordinate)
//        }
//        return shape;
//    }
//
//}
