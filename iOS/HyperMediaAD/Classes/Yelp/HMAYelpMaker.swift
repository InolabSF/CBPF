/// MARK: - HMAYelpMaker
class HMAYelpMaker: GMSMarker {

    /// MARK: - public api

    /**
     * do settings
     * @param yelpData HMAYelpData
     **/
    func doSettings(#yelpData: HMAYelpData) {
        let categoryName = yelpData.category//.lowercaseString

        var image: UIImage?
        let categories = HMAYelpCategory.fetch(category: categoryName)
        if HMAYelp.Restaurants[categoryName] != nil {
            image = UIImage(named: "marker_yelp_" + HMAYelp.Restaurants[categoryName]!)
        }
        else {
            for category in categories {
                image = UIImage(named: "marker_yelp_" + category.parent)
                if image != nil { break }
            }
        }
        if image == nil { image = UIImage(named: "marker_question") }
        self.icon = image
        self.draggable = false
    }

}
