/// MARK: - HMAYelpMaker
class HMAYelpMaker: GMSMarker {

    /// MARK: - property

    /// yelp
    var yelpData: HMAYelpData!


    /// MARK: - initialization

    convenience init(position: CLLocationCoordinate2D, yelpData: HMAYelpData) {
        self.init()

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
        self.position = position
        self.zIndex = HMAGoogleMap.ZIndex.Yelp
    }

}
