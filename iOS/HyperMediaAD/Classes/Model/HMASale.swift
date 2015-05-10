import Foundation
import CoreLocation


/// MARK: - HMASale
class HMASale: AnyObject {

    /// MARK: - property
    var title: String = ""
    var desc: String = ""
    var imageURL: NSURL?
    var imageName: String?
    var rating: Int?
    var phoneNumber: String?
    var coordinate = CLLocationCoordinate2DMake(0, 0)


    /// MARK: - initialization
    /**
     * Initialization
     * @param JSON json
     * @return Sale
     */
    convenience init(JSON: NSDictionary) {
        self.init()
        self.setJSON(JSON)
    }


    /// MARK: - public api
    /**
     * set parameters
     * @param JSON json
     */
    func setJSON(JSON: NSDictionary) {
        let titleString: AnyObject? = JSON["title"]
        if titleString != nil {
            if titleString!.isKindOfClass(NSString) { self.title = titleString as! String }
        }
        let descriptionString: AnyObject? = JSON["description"]
        if descriptionString != nil {
            if descriptionString!.isKindOfClass(NSString) { self.desc = descriptionString as! String }
        }
        let imageURLString: AnyObject? = JSON["image_url"]
        if imageURLString != nil {
            if imageURLString!.isKindOfClass(NSString) { self.imageURL = NSURL(string: imageURLString as! String) }
        }
        let imageNameString: AnyObject? = JSON["imageName"]
        if imageNameString != nil {
            if imageNameString!.isKindOfClass(NSString) { self.imageName = imageNameString as? String }
        }
        let ratingNumber: AnyObject? = JSON["rating"]
        if ratingNumber != nil {
            self.rating = reflect(ratingNumber).summary.toInt()
        }
        let phoneNumberString: AnyObject? = JSON["display_phone"]
        if phoneNumberString != nil {
            if phoneNumberString!.isKindOfClass(NSString) { self.phoneNumber = phoneNumberString as? String }
        }
        let coordinateDictionary: AnyObject? = JSON["coordinate"]
        if coordinateDictionary != nil {
            let latitude: AnyObject? = (coordinateDictionary as! NSDictionary)["latitude"]
            let longitude: AnyObject? = (coordinateDictionary as! NSDictionary)["longitude"]
            if latitude != nil && longitude != nil {
                self.coordinate = CLLocationCoordinate2DMake((latitude as! NSString).doubleValue, (longitude as! NSString).doubleValue)
            }
        }
    }
}
