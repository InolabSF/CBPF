import CoreLocation


/// MARK: - HMAHeatMapAnnotation
class HMAHeatMapAnnotation: RMAnnotation {

    /// MARK: - property
    var locations: [CLLocationCoordinate2D] = []
    var weights: [Double] = []


    /// MARK: - initialization
    init(mapView: RMMapView, coordinate: CLLocationCoordinate2D, title: String, locations: [CLLocationCoordinate2D], weights: [Double]) {
        super.init(mapView: mapView, coordinate: coordinate, andTitle: title)
        self.locations = locations
        self.weights = weights
    }


    /// MARK: - public api

    /**
     * get map layer to display cluster
     * @return layer
     */
    func getLayer(#mapView: RMMapView) -> RMMapLayer? {
        if locations.count == 0 { return nil }

        // make latitude and longitude array, sensor value array, locations array
        var points: [NSValue] = []
        var values: [NSNumber] = []
        var minLat = locations[0].latitude, maxLat = minLat
        var minLong = locations[0].longitude, maxLong = minLong
        for var i = 0; i < locations.count; i++ {
            let lat = locations[i].latitude
            let long = locations[i].longitude
            //points.append(NSValue(CGPoint: CGPointMake(CGFloat(lat), CGFloat(long))))
            values.append(NSNumber(double: weights[i]))
            if (lat < minLat) { minLat = lat }
            if (lat > maxLat) { maxLat = lat }
            if (long < minLong) { minLong = long }
            if (long > maxLong) { maxLong = long }
        }

        /*
            ^
            | longitude

            A----------B
            |          |
            |          |
            |          |
            |          |
            |          |
            C----------D     -> latitude
        */
        let coordinateC = CLLocationCoordinate2DMake(minLat, minLong)
        let coordinateD = CLLocationCoordinate2DMake(maxLat, minLong)
        let coordinateB = CLLocationCoordinate2DMake(maxLat, maxLong)
        let coordinateA = CLLocationCoordinate2DMake(minLat, maxLong)

        // calculate image width, height
        if (maxLat - minLat == 0) || (maxLat - minLat == 0) { return nil }
        //let width = (HMAMapMath.mileOfLongitude(latitude: ((minLat + maxLat) / 2.0), degree: (maxLong - minLong)) * HMAMapBox.Draw.PixelPerMile)
        //let height = (HMAMapMath.mileOfLatitude(degree: (maxLat - minLat)) * HMAMapBox.Draw.PixelPerMile)

        let height = abs(Double(mapView.coordinateToPixel(coordinateB).y - mapView.coordinateToPixel(coordinateA).y))
        let width = abs(Double(mapView.coordinateToPixel(coordinateB).x - mapView.coordinateToPixel(coordinateD).x))
        for var i = 0; i < locations.count; i++ {
            let lat = locations[i].latitude
            let long = locations[i].longitude
            //points.append(NSValue(CGPoint: CGPointMake(CGFloat(height * (lat - minLat) / (maxLat - minLat)), CGFloat(width * (long - minLong) / (maxLong - minLong)))))
            points.append(NSValue(CGPoint: CGPointMake(CGFloat(width * (long - minLong) / (maxLong - minLong)), CGFloat(height * (lat - minLat) / (maxLat - minLat)))))
        }

        // make heatmap image
        //let width = (HMAMapMath.mileOfLongitude(latitude: ((minLat + maxLat) / 2.0), degree: (maxLong - minLong)) * HMAMapBox.Draw.PixelPerMile)
        //let height = (HMAMapMath.mileOfLatitude(degree: (maxLat - minLat)) * HMAMapBox.Draw.PixelPerMile)
        let heatMapImage = LFHeatMap.heatMapWithRect(
            CGRectMake(0, 0, CGFloat(width), CGFloat(height)),
            boost: 1.0,
            points: points,
            weights: weights
        )

        // make shape
        var shape = RMShape(view: mapView)
        shape.lineColor = UIColor.clearColor()
        shape.lineWidth = 0.0;
        shape.addLineToCoordinate(coordinateC)
        shape.addLineToCoordinate(coordinateD)
        shape.addLineToCoordinate(coordinateB)
        shape.addLineToCoordinate(coordinateA)
        //shape.fillPatternImage = UIImage(named: "map_circle")
        shape.fillPatternImage = heatMapImage
        //shape.fillColor = UIColor.redColor()

        return shape
    }


}
