/// MARK: - HMACrimeMarker
class HMACrimeMarker: GMSMarker {

    /// MARK: - public api

    /**
     * do settings (design, draggable, etc)
     * @param crime HMACrimeData
     **/
    func doSettings(#crime: HMACrimeData) {
        //self.icon = HMACrimeMarker.markerImageWithColor(UIColor.blackColor())
/*
        var iconName = crime.category.lowercaseString.stringByReplacingOccurrencesOfString("/", withString: ":", options: nil, range: nil)
        var image = UIImage(named: "marker_"+iconName)
        if image == nil { image = UIImage(named: "marker_question") }
        self.icon = image
*/
        self.icon = UIImage(named: "map_marker_crime")
        self.draggable = false
        self.title = crime.category
        self.snippet = crime.desc
    }

}
