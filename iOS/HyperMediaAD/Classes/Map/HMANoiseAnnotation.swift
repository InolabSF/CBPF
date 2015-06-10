//import CoreLocation
//
//
///// MARK: - HMANoiseAnnotation
//class HMANoiseAnnotation: RMAnnotation {
//
//    /// MARK: - property
//    var soundLevel: Double!
//
//
//    /// MARK: - initialization
//
//    /**
//     * initialization
//     * @param mapView mapView
//     * @param coordinate coordinate
//     * @param title title
//     * @param soundLevel soundLevel
//     **/
//    init(mapView: RMMapView, coordinate: CLLocationCoordinate2D, title: String, soundLevel: Double) {
//        super.init(mapView: mapView, coordinate: coordinate, andTitle: title)
//        self.soundLevel = soundLevel
//
//        let longOffset = HMAMapMath.degreeOfLongitudePerRadius(
//            HMAMapBox.MilesForBoundingbox,
//            location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        )
//        let latOffset = HMAMapMath.degreeOfLatitudePerRadius(
//            HMAMapBox.MilesForBoundingbox,
//            location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        )
//        self.setBoundingBoxCoordinatesSouthWest(
//            CLLocationCoordinate2DMake(coordinate.latitude-latOffset, coordinate.longitude-longOffset),
//            northEast: CLLocationCoordinate2DMake(coordinate.latitude+latOffset, coordinate.longitude+longOffset)
//        )
//    }
//
//
//    /// MARK: - public api
//
//    /**
//     * get map layer to display cluster
//     * @return layer
//     */
//    func getLayer() -> RMMapLayer? {
///*
//        var layer = RMMarker(UIImage: UIImage(named: "map_crime"))
//        layer.opacity = Float(0.1 * self.soundLevel / 150.0)
//        layer.bounds = CGRectMake(0, 0, 100, 100)
//        layer.textForegroundColor = UIColor.whiteColor()
//        return layer
//*/
//        var circle = RMCircle(view: mapView, radiusInMeters: 10.0)
//        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
//        circle.lineColor = color//color.colorWithAlphaComponent(1.0)
//        circle.fillColor = color//color.colorWithAlphaComponent(1.0)
///*
//        var emitterLayer = CAEmitterLayer()
//        emitterLayer.renderMode = kCAEmitterLayerAdditive
//
//        var cell = CAEmitterCell()
//        cell.contents = UIImage(named: "map_particle")!.CGImage
//        cell.emissionLongitude = CGFloat(M_PI * 2)
//        cell.emissionRange = CGFloat(M_PI * 2)
//        cell.birthRate = 1000
//        cell.lifetimeRange = 1.2
//        cell.velocity = 240
//        cell.color = UIColor(red: 0.89, green:0.56, blue:0.36, alpha:0.5).CGColor
//        cell.name = ""
//
//        emitterLayer.emitterCells = [ cell, ]
//        emitterLayer.emitterPosition = CGPointMake(circle.frame.size.width / 2, circle.frame.size.height / 2)
//
//        circle.addSublayer(emitterLayer)
//*/
//        return circle;
//    }
//
//}
