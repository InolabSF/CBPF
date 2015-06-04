import CoreLocation


/// MARK: - HMACrimeAnnotation
class HMACrimeAnnotation: RMAnnotation {

    /// MARK: - property
    var desc: String!
    var resolution: String!


    /// MARK: - initialization

    /**
     * initialization
     * @param mapView mapView
     * @param coordinate coordinate
     * @param title title
     * @param desc desc
     * @param resolution resolution
     **/
    init(mapView: RMMapView, coordinate: CLLocationCoordinate2D, title: String, desc: String, resolution: String) {
        super.init(mapView: mapView, coordinate: coordinate, andTitle: title)
        self.desc = desc
        self.resolution = resolution

        let longOffset = HMAMapMath.degreeOfLongitudePerRadius(
            HMAMapBox.MilesForBoundingbox,
            location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
        let latOffset = HMAMapMath.degreeOfLatitudePerRadius(
            HMAMapBox.MilesForBoundingbox,
            location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
        self.setBoundingBoxCoordinatesSouthWest(
            CLLocationCoordinate2DMake(coordinate.latitude-latOffset, coordinate.longitude-longOffset),
            northEast: CLLocationCoordinate2DMake(coordinate.latitude+latOffset, coordinate.longitude+longOffset)
        )
    }


    /// MARK: - public api

    /**
     * get map layer to display cluster
     * @return layer
     */
    func getLayer() -> RMMapLayer? {
        var circle = RMCircle(view: mapView, radiusInMeters: 10.0)
        let color = UIColor.redColor()
        circle.lineColor = color
        circle.fillColor = color
        return circle;
/*
        var layer = RMMarker(UIImage: UIImage(named: "map_crime"))
        layer.opacity = 0.05;
        layer.bounds = CGRectMake(0, 0, 100, 100)
        layer.textForegroundColor = UIColor.whiteColor()
        return layer
*/
/*
        var circle = RMCircle(view: mapView, radiusInMeters: 250.0)
        let color = UIColor.redColor()
        circle.lineColor = color.colorWithAlphaComponent(0.2)
        circle.fillColor = color.colorWithAlphaComponent(0.2)
        return circle;
*/
    }

}
