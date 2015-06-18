/// MARK: - HMAYelpMaker
class HMAYelpMaker: GMSMarker {

    /// MARK: - property

    /// yelp
    var yelpData: HMAYelpData!


    /// MARK: - public api

    /**
     * do settings
     * @param yelpData HMAYelpData
     **/
    func doSettings(#yelpData: HMAYelpData) {
        let categoryName = yelpData.category
        var image: UIImage?
        if HMAYelp.Restaurants[categoryName] != nil {
            image = UIImage(named: "marker_yelp_" + HMAYelp.Restaurants[categoryName]!)
        }
        else {
            let categories = HMAYelpCategory.fetch(category: categoryName)
            for category in categories {
                image = UIImage(named: "marker_yelp_" + category.parent)
                if image != nil { break }
            }
        }
        if image == nil { image = UIImage(named: "marker_yelp_question") }
        self.icon = image
        self.draggable = false
        self.title = yelpData.name
        self.snippet = yelpData.category

        self.yelpData = yelpData
    }

}
