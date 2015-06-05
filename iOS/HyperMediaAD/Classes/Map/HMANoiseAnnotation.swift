import CoreLocation


/// MARK: - HMANoiseAnnotation
class HMANoiseAnnotation: RMAnnotation {

    /// MARK: - property
    var soundLevel: Double!


    /// MARK: - initialization

    /**
     * initialization
     * @param mapView mapView
     * @param coordinate coordinate
     * @param title title
     * @param soundLevel soundLevel
     **/
    init(mapView: RMMapView, coordinate: CLLocationCoordinate2D, title: String, soundLevel: Double) {
        super.init(mapView: mapView, coordinate: coordinate, andTitle: title)
        self.soundLevel = soundLevel

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
        var layer = RMMarker(UIImage: UIImage(named: "map_crime"))
        layer.opacity = 0.1 * self.soundLevel / 100.0
        layer.bounds = CGRectMake(0, 0, 100, 100)
        layer.textForegroundColor = UIColor.whiteColor()
        return layer
/*
        var circle = RMCircle(view: mapView, radiusInMeters: 250.0)
        let color = UIColor.redColor()
        circle.lineColor = color.colorWithAlphaComponent(0.2)
        circle.fillColor = color.colorWithAlphaComponent(0.2)
        return circle;
*/
    }

}
