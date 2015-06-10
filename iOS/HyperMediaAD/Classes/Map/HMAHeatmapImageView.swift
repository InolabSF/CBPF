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

        var points: [NSValue] = []
        for var i = 0; i < locations.count; i++ {
            let location = locations[i]
            points.append(NSValue(CGPoint: mapView.projection.pointForCoordinate(location.coordinate)))
        }
        self.image = LFHeatMap.heatMapWithRect(mapView.frame, boost: boost, points: points, weights: weights)
    }

}
