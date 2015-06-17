/// MARK: - HMAYelpMaker
class HMAYelpMaker: GMSMarker {

    /// MARK: - public api

    /**
     * do settings
     * @param yelpData HMAYelpData
     **/
    func doSettings(#yelpData: HMAYelpData) {
        var iconName = yelpData.category
        var image = UIImage(named: "marker_yelp_"+iconName)
        if image == nil { image = UIImage(named: "marker_question") }
        self.icon = image
        self.draggable = false
    }

}
