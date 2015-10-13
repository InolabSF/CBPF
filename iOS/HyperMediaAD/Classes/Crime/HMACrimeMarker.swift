/// MARK: - HMACrimeMarkerImage
struct HMACrimeMakerImage {
    /// violence
    static let Violence = UIImage.circleImage(size: CGSizeMake(16.0, 16.0), color: UIColor(red: 255.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.35))
    /// stealing vihicle
    static let StealingVihicle = UIImage.circleImage(size: CGSizeMake(16.0, 16.0), color: UIColor(red: 0.0 / 255.0, green: 128.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.35))
    /// traffic violation
    static let TrafficViolation = UIImage.circleImage(size: CGSizeMake(16.0, 16.0), color: UIColor(red: 0.0 / 255.0, green: 160.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.35))
}


/// MARK: - HMACrimeMarker
class HMACrimeMarker: /*GMSCircle*/GMSMarker {

    /// MARK: - initialization

    convenience init(position: CLLocationCoordinate2D, crime: HMACrimeData) {
        self.init()
/*
        // icon
        var iconName = crime.category.lowercaseString
        var image = UIImage(named: "marker_crime_"+iconName)
        if image == nil { image = UIImage(named: "marker_question") }
        self.icon = image

        // settings
        self.position = position
        self.draggable = false
        self.title = crime.category
        self.snippet = crime.desc
        self.zIndex = HMAGoogleMap.ZIndex.Crime
*/

        // icon
        self.setIcon(crime: crime)
        // settings
        self.position = position
        self.draggable = false
        self.title = crime.category
        self.snippet = crime.desc
        self.zIndex = HMAGoogleMap.ZIndex.Crime

/*
        self.setColor(crime: crime)
        // settings
        self.position = position
        self.zIndex = HMAGoogleMap.ZIndex.Crime
        self.radius = 50.0
*/
    }


    /// MARK: - private api

    /**
     * set icon
     * @param crime HMACrimeData
     **/
    private func setIcon(crime crime: HMACrimeData) {
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
        let images = [
            "violence" : HMACrimeMakerImage.Violence,
            "stealing_vihicle" : HMACrimeMakerImage.StealingVihicle,
            "traffic_violation" : HMACrimeMakerImage.TrafficViolation,
        ]

        for (iconName, descs) in iconNames {
            for desc in descs {
                if crime.desc.rangeOfString(desc) == nil { continue }

                // contains
                //self.icon = UIImage(named: "crime_marker_" + iconName)
                //self.icon = UIImage.circleImage(size: CGSizeMake(20.0, 20.0), color: fillColors[iconName]!)
                self.icon = images[iconName]
                return
            }
        }
    }

    /**
     * set icon
     * @param crime HMACrimeData
     **/
/*
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

        for (category, descs) in categories {
            for desc in descs {
                if crime.desc.rangeOfString(desc) == nil { continue }

                // contains
                self.fillColor = fillColors[category]
                self.strokeColor = UIColor.clearColor()
                break
            }
        }
    }
*/
}
