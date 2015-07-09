import Foundation
import CoreData
import CoreLocation


/// MARK: - HMAYelpCategory
class HMAYelpCategory: NSManagedObject {

    /// MARK: - property
    @NSManaged var alias: String
    @NSManaged var title: String
    @NSManaged var parent: String


    /// MARK: - public class method

    /**
     * create coredata
     **/
    class func create() {
        let path = NSBundle.mainBundle().pathForResource("yelp_categories", ofType: "json")
        if path == nil { return }
        var error: NSError? = nil
        let jsonData = NSData(contentsOfFile:path!, options: .DataReadingMappedIfSafe, error: &error)
        if jsonData == nil || error != nil { return }
        let json = JSON(data: jsonData!)

        HMAYelpCategory.save(json: json)
    }

    /**
     * fetch datas from coredata
     * @category String
     * @return [HMAYelpCategory]
     */
    class func fetch(#category: String) -> [HMAYelpCategory] {
        if !(HMAYelpCategory.hasData()) { return [] }

        var context = HMACoreDataManager.sharedInstance.managedObjectContext
        // make fetch request
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMAYelpCategory", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
            // make predicate
        let predicaets = [
            NSPredicate(format: "(alias = %@) OR (title = %@)", category, category),
        ]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicaets)

        // return yelp category
        var error: NSError? = nil
        let categries = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil || categries == nil { return [] }
        return categries as! [HMAYelpCategory]
    }

    /**
     * save data
     * @json JSON
     */
    class func save(#json: JSON) {
        if HMAYelpCategory.hasData() { return }

        let categories = json.arrayValue

        var context = HMACoreDataManager.sharedInstance.managedObjectContext
        for category in categories {
            let parents = category["parents"].arrayValue
            if parents.count == 0 { continue }

            var yelp = NSEntityDescription.insertNewObjectForEntityForName("HMAYelpCategory", inManagedObjectContext: context) as! HMAYelpCategory
            yelp.alias = category["alias"].stringValue
            yelp.title = category["title"].stringValue
            yelp.parent = parents[0].stringValue
        }

        var error: NSError? = nil
        !context.save(&error)
        if error == nil && !(HMAYelpCategory.hasData()) {
            NSUserDefaults().setBool(true, forKey: HMAUserDefaults.YelpCategory)
            NSUserDefaults().synchronize()
        }
    }


    /// MARK: - private class method

    /**
     * check if app has yelp category type
     * @return Bool
     **/
    private class func hasData() -> Bool {
        return NSUserDefaults().boolForKey(HMAUserDefaults.YelpCategory)
    }
}

