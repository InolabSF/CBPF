/// MARK: - HMACrimeMarker
class HMACrimeMarker: GMSMarker {

    /// MARK: - initialization

    convenience init(position: CLLocationCoordinate2D, crime: HMACrimeData) {
        self.init()

/*
        // icon
        var iconName = crime.category.lowercaseString
        var image = UIImage(named: "marker_crime_"+iconName)
        if image == nil { image = UIImage(named: "marker_question") }
        self.icon = image
*/
        self.setIcon(crime: crime)

        // settings
        self.position = position
        self.draggable = false
        self.title = crime.category
        self.snippet = crime.desc
        self.zIndex = HMAGoogleMap.ZIndex.Crime
    }


    /// MARK: -

    /**
     * set icon
     * @param crime HMACrimeData
     **/
    func setIcon(#crime: HMACrimeData) {
        let iconNames = [
            "violence" : [
                "GUN",
                "KNIFE",
                "WEAPON",
                "FIREARM",
                "BATTERY",
                "ASSAULT",
                "RAPE",
                "SHOOTING",
            ],
            "stealing_vihicle" : [
                "THEFT BICYCLE",
                "STOLEN AUTO",
                "STOLEN MOTOR",
                "STOLEN TRUCK",
            ],
            "traffic_violation" : [
                "DRIVING",
                "SPEEDING",
                "TRAFFIC VIOLATION",
                "ALCOHOL",
            ],
        ]
        for (iconName, descs) in iconNames {
            for desc in descs {
                if crime.desc.rangeOfString(desc) == nil { continue }

                // contains
                self.icon = UIImage(named: "crime_marker_" + iconName)
                return
            }
        }
    }

}
