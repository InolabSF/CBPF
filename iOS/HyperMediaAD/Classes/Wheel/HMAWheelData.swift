import Foundation
import CoreData


/// MARK: - HMAWheelData
class HMAWheelData: NSManagedObject {

    /// MARK: - property
    @NSManaged var data_type : NSNumber
    @NSManaged var value : NSNumber
    @NSManaged var lat : NSNumber
    @NSManaged var long : NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var timestamp : NSDate

}
