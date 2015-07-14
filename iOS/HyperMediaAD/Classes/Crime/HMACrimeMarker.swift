/// MARK: - HMACrimeMarker
class HMACrimeMarker: GMSCircle/*GMSMarker*/ {

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
//        self.setIcon(crime: crime)

        // settings
        self.position = position
/*
        self.draggable = false
        self.title = crime.category
        self.snippet = crime.desc
*/
        self.zIndex = HMAGoogleMap.ZIndex.Crime

        self.radius = 50.0
        self.setColor(crime: crime)
//        self.strokeWidth = 1.0
    }


    /// MARK: - private api

    /**
     * set icon
     * @param crime HMACrimeData
     **/
/*
    private func setIcon(#crime: HMACrimeData) {
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
*/
    /**
     * set icon
     * @param crime HMACrimeData
     **/
    private func setColor(#crime: HMACrimeData) {
        let categories = [
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
        let fillColors = [
            "violence" : UIColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.35),
            "stealing_vihicle" : UIColor(red: 0.0 / 255.0, green: 160.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.35),
            "traffic_violation" : UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.35),
        ]
/*
        let strokeColors = [
            "violence" : UIColor(red: 128.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.35),
            "stealing_vihicle" : UIColor(red: 0.0 / 255.0, green: 80.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.35),
            "traffic_violation" : UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 80.0 / 255.0, alpha: 0.35),
        ]
*/

        for (category, descs) in categories {
            for desc in descs {
                if crime.desc.rangeOfString(desc) == nil { continue }

                // contains
                self.fillColor = fillColors[category]
                //self.strokeColor = strokeColors[category]
                self.strokeColor = UIColor.clearColor()
                break
            }
        }
    }

}
