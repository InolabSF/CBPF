/// MARK: - UIImage+HMAHeatmap
extension UIImage {

    /// MARK: - initialization

    /**
     * make heatmap imageView for GMSMapView
     * @param mapView GMSMapView
     * @param locations [CLLocation]
     * @param weights [NSNumber]
     * @param boost Float
     * @return HMAHeatmapImageView
     **/
    class func heatmapImage(#mapView: GMSMapView, locations: [CLLocation], weights: [NSNumber], boost: Float) -> UIImage {
        var points: [NSValue] = []
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            points.append(NSValue(CGPoint: mapView.projection.pointForCoordinate(location.coordinate)))
        }
        return LFHeatMap.heatMapWithRect(mapView.frame, boost: boost, points: points, weights: weights)
    }

}

/// MARK: - HMAHeatmapImageView
class HMAHeatmapImageView: UIImageView {

    /// MARK: - property


    /// MARK: - initialization

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     * make heatmap imageView for GMSMapView
     * @param mapView GMSMapView
     * @param locations [CLLocation]
     * @param weights [NSNumber]
     * @param boost Float
     * @return HMAHeatmapImageView
     **/
    init(mapView: GMSMapView, locations: [CLLocation], weights: [NSNumber], boost: Float) {
        super.init(frame: mapView.frame)

        self.image = UIImage.heatmapImage(mapView: mapView, locations: locations, weights: weights, boost: boost)
    }

}
