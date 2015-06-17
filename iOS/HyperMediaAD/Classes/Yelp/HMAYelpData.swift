import Foundation
import CoreData
import CoreLocation


/// MARK: - HMAYelpData
class HMAYelpData: NSObject {

    /// MARK: - property
    var category: String!
    var coordinate: CLLocationCoordinate2D!
    var name: String!
    var phone: String!
    var mobile_url: NSURL?


    /// MARK: - initialization

    /**
     * Initialization
     * @param json json
     * @return HMAYelpData
     */
    init(json: JSON) {
        super.init()

        self.setJSON(json)
    }


    /// MARK: - private api

    /**
     * set property by json
     * @param json json
     **/
    private func setJSON(json: JSON) {
        self.name = json["name"].stringValue
        self.phone = json["phone"].stringValue
        self.mobile_url = NSURL(string: json["mobile_url"].stringValue)

        let location = json["location"]
        if location != nil {
            let coordinate = location["coordinate"]
            self.coordinate = CLLocationCoordinate2DMake(coordinate["latitude"].doubleValue, coordinate["longitude"].doubleValue)
        }

        let categoryLists = json["categories"]
        if categoryLists == nil { return }
        let categories = categoryLists.arrayValue
        if categories.count == 0 { return }
        self.category = categories[0].stringValue
    }
}
