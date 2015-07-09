import Foundation
import CoreData
import CoreLocation


/// MARK: - HMACrimeData
class HMACrimeData: NSManagedObject {


    /// MARK: - property
    @NSManaged var category: String
    @NSManaged var desc: String
    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var timestamp: NSDate


    /// MARK: - public class method

    /**
     * request to get crime data to server
     **/
    class func requestToGetCrimeData() {
        var coordinate = HMAMapView.sharedInstance.centerCoordinate()
        HMACoreDataManager.deleteAllDataIfNeeds(currentLocation: coordinate)

        // crime API
        if HMACrimeData.hasData() { return }

        HMACrimeClient.sharedInstance.cancelGetCrime()
        HMACrimeClient.sharedInstance.getCrime(
            radius: HMAAPI.Radius,
            coordinate: coordinate,
            completionHandler: { (json) in
                HMACrimeData.save(json: json)
            }
        )
    }

    /**
     * fetch datas from coredata
     * @param minimumCoordinate CLLocationCoordinate2D
     * @param maximumCoordinate CLLocationCoordinate2D
     * @return Array<HMACrimeData>
     */
    class func fetch(#minimumCoordinate: CLLocationCoordinate2D, maximumCoordinate: CLLocationCoordinate2D) -> Array<HMACrimeData> {
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMACrimeData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
            // time
        let currentDate = NSDate()
        var startDate = currentDate.hma_monthAgo(months: HMACrime.MonthsAgo)
        var endDate = startDate!.hma_daysLater(days: HMACrime.Days)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.stringFromDate(startDate!)
        let endDateString = dateFormatter.stringFromDate(endDate!)
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        startDate = dateFormatter.dateFromString(startDateString+" 00:00:00")
        endDate = dateFormatter.dateFromString(endDateString+" 00:00:00")
            // rect
        let predicaets = [
            //NSPredicate(format: "(timestamp >= %@) AND (timestamp < %@)", startDate!, endDate!),
            NSPredicate(format: "(lat <= %@) AND (lat >= %@)", NSNumber(double: maximumCoordinate.latitude), NSNumber(double: minimumCoordinate.latitude)),
            NSPredicate(format: "(long <= %@) AND (long >= %@)", NSNumber(double: maximumCoordinate.longitude), NSNumber(double: minimumCoordinate.longitude)),
        ]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicaets)

        // return crimes
        var error: NSError? = nil
        let crimeDatas = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil || crimeDatas == nil {
            return []
        }
        return crimeDatas as! Array<HMACrimeData>
    }

    /**
     * fetch datas from coredata
     * @param location location
     * @param radius radius of miles
     * @return Array<HMACrimeData>
     */
    class func fetch(#location: CLLocation, radius: Double) -> Array<HMACrimeData> {
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMACrimeData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
            // time
        let currentDate = NSDate()
        var startDate = currentDate.hma_monthAgo(months: HMACrime.MonthsAgo)
        var endDate = startDate!.hma_daysLater(days: HMACrime.Days)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.stringFromDate(startDate!)
        let endDateString = dateFormatter.stringFromDate(endDate!)
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        startDate = dateFormatter.dateFromString(startDateString+" 00:00:00")
        endDate = dateFormatter.dateFromString(endDateString+" 00:00:00")
            // rect
        let coordinate = location.coordinate
        let latOffset = HMAMapMath.degreeOfLatitudePerRadius(radius, location: location)
        let longOffset = HMAMapMath.degreeOfLongitudePerRadius(radius, location: location)
        let predicaets = [
            //NSPredicate(format: "(timestamp >= %@) AND (timestamp < %@)", startDate!, endDate!),
            NSPredicate(format: "(lat <= %@) AND (lat >= %@)", NSNumber(double: coordinate.latitude + latOffset), NSNumber(double: coordinate.latitude - latOffset)),
            NSPredicate(format: "(long <= %@) AND (long > %@)", NSNumber(double: coordinate.longitude + longOffset), NSNumber(double: coordinate.longitude - longOffset)),
        ]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicaets)

        // return crimes
        var error: NSError? = nil
        let crimes = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil || crimes == nil {
            return []
        }
        return crimes as! Array<HMACrimeData>
    }

    /**
     * save json datas to coredata
     * @param json JSON
     * [
     *   {
     *     "category" : "LARCENY/THEFT",
     *     "lat" : "37.7841893501425",
     *     "long" : "-122.407633520742",
     *     "desc" : "PETTY THEFT SHOPLIFTING",
     *     "resolution" : "ARREST, BOOKED",
     *     "timestamp" : "2015-02-03T00:00:00",
     *   },
     *   ...
     * ]
     */
    class func save(#json: JSON) {
        if HMACrimeData.hasData() { return }

        HMACrimeData.delete()

        let crimeDatas: Array<JSON> = json["crime_datas"].arrayValue
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        let dateFormatter = NSDateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        for crimeData in crimeDatas {
            let yyyymmddhhmmssSSS = crimeData["timestamp"].stringValue
            let timestamp = dateFormatter.dateFromString(yyyymmddhhmmssSSS)
            if timestamp == nil { continue }

            var crime = NSEntityDescription.insertNewObjectForEntityForName("HMACrimeData", inManagedObjectContext: context) as! HMACrimeData
            crime.category = crimeData["category"].stringValue
            crime.desc = crimeData["desc"].stringValue
            crime.lat = crimeData["lat"].numberValue
            crime.long = crimeData["long"].numberValue
            crime.timestamp = timestamp!
        }

        var error: NSError? = nil
        !context.save(&error)

        if error == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentYearMonth = dateFormatter.stringFromDate(NSDate())
            NSUserDefaults().setObject(currentYearMonth, forKey: HMAUserDefaults.CrimeYearMonth)
            NSUserDefaults().synchronize()
        }
    }

    /**
     * delete all crimeDatas
     **/
    class func delete() {
        var context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMACrimeData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20

        // get all crimes
        var error: NSError? = nil
        let crimeDatas = context.executeFetchRequest(fetchRequest, error: &error) as? [HMACrimeData]
        if error != nil || crimeDatas == nil {
            return
        }

        // delete
        for crimeData in crimeDatas! {
            context.deleteObject(crimeData)
        }
        NSUserDefaults().setObject("", forKey: HMAUserDefaults.CrimeYearMonth)
        NSUserDefaults().synchronize()
    }


    /// MARK: - private class method

    /**
     * check if client needs to get new crime data
     * @return Bool
     **/
    private class func hasData() -> Bool {
        let crimeYearMonth = NSUserDefaults().stringForKey(HMAUserDefaults.CrimeYearMonth)

        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentYearMonth = dateFormatter.stringFromDate(NSDate())

        return (crimeYearMonth == currentYearMonth)
    }

}
