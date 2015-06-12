/// MARK: - HMAClusterMarker
class HMAClusterMarker: GMSMarker {

    /// MARK: - property


    /// MARK: - initialization

    /**
     * make a marker that shows cluster data of certain rectangle area
     * @param mapView HMAMapView
     * @param minimumPoint CGPoint on mapView
     * @param maximumPoint CGPoint on mapView
     * @param crimes [HMACrimeData]
     * @return HMAClusterMarker
     **/
    init(
        mapView: HMAMapView,
        minimumPoint: CGPoint,
        maximumPoint: CGPoint,
        crimes: [HMACrimeData]
    ) {
        super.init()

        self.draggable = false
        self.opacity = 0.5

        // evaluation for cluster
            // count crimes
        var count: Double = 0.0
        let points = [ minimumPoint, CGPointMake(maximumPoint.x, minimumPoint.y), CGPointMake(minimumPoint.x, maximumPoint.y), maximumPoint, ]
        let min = mapView.minimumCoordinate(mapViewPoints: points)
        let max = mapView.maximumCoordinate(mapViewPoints: points)
        for crime in crimes {
            let lat = crime.lat.doubleValue
            let long = crime.long.doubleValue
            if (lat > min.latitude && long > min.longitude) && (lat < max.latitude && long < max.longitude) { count = count + 1.0 }
        }
            // calculate square miles
        let coordOfMinXMinY = mapView.projection.coordinateForPoint(points[0])
        let coordOfMaxXMinY = mapView.projection.coordinateForPoint(points[1])
        let coordOfMinXMaxY = mapView.projection.coordinateForPoint(points[2])
        let width = HMAMapMath.mileFromMeter(CLLocation(latitude: coordOfMinXMinY.latitude, longitude: coordOfMinXMinY.longitude).distanceFromLocation(CLLocation(latitude: coordOfMaxXMinY.latitude, longitude: coordOfMaxXMinY.longitude)))
        let height = HMAMapMath.mileFromMeter(CLLocation(latitude: coordOfMinXMinY.latitude, longitude: coordOfMinXMinY.longitude).distanceFromLocation(CLLocation(latitude: coordOfMinXMaxY.latitude, longitude: coordOfMinXMaxY.longitude)))
        let squareMiles = width * height
            // evaluate
        var evaluation = CGFloat((squareMiles == 0) ? 0.0 : count / squareMiles / HMACrime.NumberPerSquareMiles)
        if evaluation == 0.0 { self.opacity = 0.0 }
        else { evaluation = 1.0 / evaluation }

        // cluster
        let originalImage = UIImage(named: "marker_cluster") as UIImage!
        self.icon = UIImage(CGImage: originalImage.CGImage, scale: originalImage.scale * evaluation, orientation: originalImage.imageOrientation)

        // position
        self.position = mapView.projection.coordinateForPoint(
                CGPointMake((minimumPoint.x + maximumPoint.x) / 2.0, (minimumPoint.y + maximumPoint.y) / 2.0 + self.icon.size.height / 2.0)
        )
    }

}
