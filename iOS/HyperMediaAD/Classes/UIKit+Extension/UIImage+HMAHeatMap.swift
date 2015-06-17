/// MARK: - UIImage+HMAHeatMap
extension UIImage {

    /// MARK: - initialization

    /**
     * make heatmap imageView for GMSMapView
     * @param mapView GMSMapView
     * @param locations [CLLocation]
     * @param weights [NSNumber]
     * @param boost Float
     * @return HMAHeatMapImageView
     **/
    class func heatmapImage(#mapView: GMSMapView, locations: [CLLocation], weights: [NSNumber], boost: Float) -> UIImage {
        var points: [NSValue] = []
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            points.append(NSValue(CGPoint: mapView.projection.pointForCoordinate(location.coordinate)))
        }
        return HMAHeatMap.heatMapWithRect(mapView.frame, boost: boost, points: points, weights: weights)
    }

}
