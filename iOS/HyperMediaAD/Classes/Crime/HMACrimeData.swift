import Foundation
import CoreData
import CoreLocation


/// MARK: - HMACrimeData
class HMACrimeData: NSManagedObject {

    /// MARK: - property
    @NSManaged var desc: String
    @NSManaged var resolution: String
    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var timestamp: NSDate


    /// MARK: - class method

    /**
     * fetch datas from coredata
     * @param location location
     * @param radius radius of miles
     * @return Array<HMACrimeData>
     */
    class func fetch(#location: CLLocation, radius: Double) -> Array<HMACrimeData> {
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMACrimeData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20

        let coordinate = location.coordinate
        let latOffset = HMAMapMath.degreeOfLatitudePerRadius(radius, location: location)
        let longOffset = HMAMapMath.degreeOfLongitudePerRadius(radius, location: location)
        let predicaets = [
            NSPredicate(format: "lat < %@", NSNumber(double: coordinate.latitude + latOffset)),
            NSPredicate(format: "lat > %@", NSNumber(double: coordinate.latitude - latOffset)),
            NSPredicate(format: "long < %@", NSNumber(double: coordinate.longitude + longOffset)),
            NSPredicate(format: "long > %@", NSNumber(double: coordinate.longitude - longOffset)),
        ]
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicaets)

        var error: NSError? = nil
        let crimes = context.executeFetchRequest(fetchRequest, error: &error) as! Array<HMACrimeData>
        return crimes
    }

    /**
     * save json datas to coredata
     * @param json JSON
     * [
     *   {
     *     "time" : "08:42",
     *     "category" : "LARCENY/THEFT",
     *     "pddistrict" : "SOUTHERN",
     *     "pdid" : "13054930206362",
     *     "location" : {
     *       "needs_recoding" : false,
     *       "longitude" : "-122.407633520742",
     *       "latitude" : "37.7841893501425",
     *       "human_address" : "{\"address\":\"\",\"city\":\"\",\"state\":\"\",\"zip\":\"\"}"
     *     },
     *     "address" : "800 Block of MARKET ST",
     *     "descript" : "PETTY THEFT SHOPLIFTING",
     *     "dayofweek" : "Tuesday",
     *     "resolution" : "ARREST, BOOKED",
     *     "date" : "2015-02-03T00:00:00",
     *     "y" : "37.7841893501425",
     *     "x" : "-122.407633520742",
     *     "incidntnum" : "130549302"
     *   },
     *   ...
     * ]
     */
/*
    class func save(#json: JSON) {
        if HMACrimeData.hasData() { return }

        let crimeDatas: Array<JSON> = json.arrayValue
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        let dateFormatter = NSDateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        for crimeData in crimeDatas {
            var crime = NSEntityDescription.insertNewObjectForEntityForName("HMACrimeData", inManagedObjectContext: context) as! HMACrimeData
            crime.desc = crimeData["descript"].stringValue
            crime.resolution = crimeData["resolution"].stringValue
            if let location = crimeData["location"].dictionary {
                crime.lat = location["latitude"]!.numberValue
                crime.long = location["longitude"]!.numberValue
            }
            let yyyymmddhhmm = (crimeData["date"].stringValue).stringByReplacingOccurrencesOfString("T00:00:00", withString: " ") + crimeData["time"].stringValue
            crime.timestamp = dateFormatter.dateFromString(yyyymmddhhmm)!
        }

        var error: NSError? = nil
        !context.save(&error)

        if error == nil {
            dateFormatter.dateFormat = "yyyy/MM"
            let currentYearMonth = dateFormatter.stringFromDate(NSDate())
            NSUserDefaults().setObject(currentYearMonth, forKey: HMAUserDefaults.CrimeYearMonth)
            NSUserDefaults().synchronize()
        }
    }
*/

    /**
     * check if client needs to get new crime data
     * @return Bool
     **/
    class func hasData() -> Bool {
        let crimeYearMonth = NSUserDefaults().stringForKey(HMAUserDefaults.CrimeYearMonth)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM"
        let currentYearMonth = dateFormatter.stringFromDate(NSDate())

        return (crimeYearMonth == currentYearMonth)
    }


}