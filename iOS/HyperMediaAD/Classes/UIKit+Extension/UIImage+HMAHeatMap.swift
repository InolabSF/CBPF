/// MARK: - UIImage+HMAHeatMap
extension UIImage {

    /// MARK: - initialization

    /**
     * make heatIndex heatmap imageView for GMSMapView
     * @param mapView GMSMapView
     * @param frame CGRect
     * @param locations [CLLocation]
     * @param weights [NSNumber]
     * @param boost Float
     * @return HMAHeatMapImageView
     **/
    class func heatIndexHeatmapImage(mapView mapView: GMSMapView, frame: CGRect, locations: [CLLocation], weights: [NSNumber], boost: Float) -> UIImage {
        var points: [NSValue] = []
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            points.append(NSValue(CGPoint: mapView.projection.pointForCoordinate(location.coordinate)))
        }
        return HMAHeatMap.heatIndexHeatmapWithRect(frame, boost: boost, points: points, weights: weights)
    }

    /**
     * make crime heatmap imageView for GMSMapView
     * @param mapView GMSMapView
     * @param locations [CLLocation]
     * @param weights [NSNumber]
     * @param boost Float
     * @return HMAHeatMapImageView
     **/
    class func crimeHeatmapImage(mapView mapView: GMSMapView, locations: [CLLocation], weights: [NSNumber], boost: Float) -> UIImage {
        var points: [NSValue] = []
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            points.append(NSValue(CGPoint: mapView.projection.pointForCoordinate(location.coordinate)))
        }
        return HMAHeatMap.crimeHeatmapWithRect(mapView.frame, boost: boost, points: points, weights: weights)
    }

}
