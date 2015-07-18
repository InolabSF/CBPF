/// MARK: - JSON+HMARoute
extension JSON {

    /// MARK: - public api

    /**
     * return encodedPath
     * @return String or nil
     **/
    func encodedPath() -> String? {
        let json = self
        let routes = json["routes"].arrayValue
        for route in routes {
            let overviewPolyline = route["overview_polyline"].dictionaryValue
            let path = overviewPolyline["points"]!.stringValue
            return path
        }

        return nil
    }

    /**
     * return end location
     * @return CLLocationCoordinate2D or nil
     **/
    func endLocation() -> CLLocationCoordinate2D? {
        let json = self
        let routes = json["routes"].arrayValue
        for route in routes {
            let legs = route["legs"].arrayValue
            for leg in legs {
                if let locationDictionary = leg["end_location"].dictionary {
                    return CLLocationCoordinate2D(latitude: locationDictionary["lat"]!.doubleValue, longitude: locationDictionary["lng"]!.doubleValue)
                }
            }
        }

        return nil
    }

    /**
     * return routeDuration
     * @return seconds Int
     **/
    func routeSeconds() -> Int {
        var seconds = 0
        let json = self
        let routes = json["routes"].arrayValue
        for route in routes {
            let legs = route["legs"].arrayValue
            for leg in legs {
                let duration = leg["duration"].dictionaryValue
                seconds += duration["value"]!.intValue
            }
        }
        return seconds
    }

    /**
     * return endAddress
     * @return String ex) "711B Market Street, San Francisco, CA 94103, USA" or nil
     **/
    func endAddress() -> String? {
        let json = self
        let routes = json["routes"].arrayValue
        for route in routes {
            let legs = route["legs"].arrayValue
            if legs.count > 0 {
                let leg = legs[legs.count - 1]
                return leg["end_address"].stringValue
            }

        }
        return nil
    }

}
