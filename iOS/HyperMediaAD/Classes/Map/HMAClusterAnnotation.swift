import CoreLocation


/// MARK: - HMAClusterAnnotation
class HMAClusterAnnotation: RMAnnotation {

    /// MARK: - property
    var sensorType: Int!
    var sensorValue: Double!


    /// MARK: - initialization
    init(mapView: RMMapView, coordinate: CLLocationCoordinate2D, title: String, sensorType: Int, sensorValue: Double) {
        super.init(mapView: mapView, coordinate: coordinate, andTitle: title)
        self.sensorType = sensorType
        self.sensorValue = sensorValue

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
        let clusterValue = self.sensorValue

        var layer = RMMarker(UIImage: UIImage(named: "map_circle"))
        layer.opacity = 0.75;
        layer.bounds = CGRectMake(0, 0, CGFloat(clusterValue), CGFloat(clusterValue))
        layer.textForegroundColor = UIColor.whiteColor()
        layer.changeLabelUsingText(String(format: "%.0fF", clusterValue))
        return layer
    }


}
