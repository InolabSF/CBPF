/// MARK: - HMACrimeMarker
class HMACrimeMarker: GMSMarker {

    /// MARK: - initialization

    convenience init(position: CLLocationCoordinate2D, crime: HMACrimeData) {
        self.init()

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
    }

}
