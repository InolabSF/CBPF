/// MARK: - HMAMapView
class HMAMapView: RMMapView {


    /// MARK: - public api

    /**
     * get map layer
     * @param annotation annotation
     * @return RMMapLayer?
     **/
    func getLayer(#annotation: RMAnnotation) -> RMMapLayer? {
        var layer: RMMapLayer? = nil

        // route
        if annotation.isKindOfClass(HMARouteAnnotation) {
            let routeAnnotation = annotation as! HMARouteAnnotation
            layer = routeAnnotation.getLayer(mapView: self)
        }
        // heat map
        else if annotation.isKindOfClass(HMAHeatMapAnnotation) {
            let heatMapAnnotation = annotation as! HMAHeatMapAnnotation
            layer = heatMapAnnotation.getLayer(mapView: self)
        }
        // cluster
        else if annotation.isKindOfClass(HMAClusterAnnotation) {
            let clusterAnnotation = annotation as! HMAClusterAnnotation
            layer = clusterAnnotation.getLayer()
        }
        // crime
        else if annotation.isKindOfClass(HMACrimeAnnotation) {
            let crimeAnnotation = annotation as! HMACrimeAnnotation
            layer = crimeAnnotation.getLayer()
        }

        return layer
    }

    /**
     * set route with location points
     * @param json json
     **/
    func setRouteFromGoogleMapAPIDirections(#json: JSON) {
        // remove
        self.removeKindOfAnnotationClass(HMARouteAnnotation)

        // add
        let locationsList = self.locationsListFromGoogleMapAPIDirections(json: json)
        for locations in locationsList {
            var annotation = HMARouteAnnotation(
                mapView: self,
                coordinate: locations[0].coordinate,
                title: "Start",
                locations: locations
            )
            annotation.userInfo = locations
            annotation.setBoundingBoxFromLocations(locations)
            self.addAnnotation(annotation)
        }
    }

    /**
     * set tempature annotation
     * @param json json
     **/
    func setTempatureAnnotation(#json: JSON) {
        let sensorDatas = json["sensor_datas"].arrayValue
        if sensorDatas.count == 0 { return }

        // heatmap
        var weights: [Double] = []
        var locations: [CLLocationCoordinate2D] = []
        for var i = 0; i < sensorDatas.count; i++ {
            let sensorData = sensorDatas[i]
            weights.append(sensorData["value"].doubleValue)
            locations.append(CLLocationCoordinate2DMake(sensorData["lat"].doubleValue, sensorData["long"].doubleValue))
        }

        let tempatureAnnotation = HMAHeatMapAnnotation(
            mapView: self,
            coordinate: CLLocationCoordinate2DMake(0, 0),
            title: "",
            locations: locations,
            weights: weights
        )
        self.addAnnotation(tempatureAnnotation)
/*
        // cluster
        for sensorData in sensorDatas {
            let annotation = HMAClusterAnnotation(
                mapView: self,
                coordinate: CLLocationCoordinate2DMake(sensorData["lat"].doubleValue, sensorData["long"].doubleValue),
                title: "",
                sensorType: HMASensor.SensorType.Temperature,
                sensorValue: sensorData["value"].doubleValue
            )
            self.addAnnotation(annotation)
        }
*/
    }

    /**
     * set crime annotation
     * @param json json
     **/
    func setCrimeAnnotation(#json: JSON) {
        self.removeKindOfAnnotationClass(HMACrimeAnnotation)

        let crimeDatas = json["crime_datas"].arrayValue
        if crimeDatas.count == 0 { return }

        for crimeData in crimeDatas {
            let annotation = HMACrimeAnnotation(
                mapView: self,
                coordinate: CLLocationCoordinate2DMake(crimeData["lat"].doubleValue, crimeData["long"].doubleValue),
                title: crimeData["desc"].stringValue,
                desc: crimeData["desc"].stringValue,
                resolution: crimeData["resolution"].stringValue
            )
            self.addAnnotation(annotation)
        }
    }

    /**
     * has kind of annotation?
     * @param annotationClass anotation's class
     * @return true or false
     **/
    func hasKindOfAnnotationClass(annotationClass: AnyClass) -> Bool {
        for annotation in self.annotations {
            if annotation.isKindOfClass(annotationClass) { return true }
        }
        return false
    }

    /**
     * remove kind of annotation
     * @param annotationClass anotation's class
     **/
    func removeKindOfAnnotationClass(annotationClass: AnyClass) {
        for annotation in self.annotations {
            if annotation.isKindOfClass(annotationClass) { self.removeAnnotation(annotation as! RMAnnotation) }
        }
    }


    /// MARK: - private api

    /**
     * return locations array from google map directions API response JSON
     * @param json json
     * @return [[CLLocation]]
     **/
    func locationsListFromGoogleMapAPIDirections(#json: JSON) -> [[CLLocation]] {
        // make locations list
        var locationsList = [] as [[CLLocation]]

        let routes = json["routes"].arrayValue
        for route in routes {
            let legs = route["legs"].arrayValue
            for leg in legs {
                // make locations
                var locations = [] as [CLLocation]
                // steps
                let steps = leg["steps"].arrayValue
                for var i = 0; i < steps.count; i++ {
                    let step = steps[i]
                    // start_location
                    let start = CLLocation(
                        latitude: step["start_location"].dictionaryValue["lat"]!.doubleValue,
                        longitude: step["start_location"].dictionaryValue["lng"]!.doubleValue
                    )
                    locations.append(start)
                    // end_location
                    if i == steps.count - 1 {
                        let end = CLLocation(
                            latitude: step["end_location"].dictionaryValue["lat"]!.doubleValue,
                            longitude: step["end_location"].dictionaryValue["lng"]!.doubleValue
                        )
                        locations.append(end)
                    }
                }
                locationsList.append(locations)
            }
        }

        return locationsList
    }

}
