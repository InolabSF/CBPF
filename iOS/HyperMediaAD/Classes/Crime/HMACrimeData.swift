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
        let coordinate = HMAMapView.sharedInstance.centerCoordinate()
        HMACoreDataManager.deleteAllDataIfNeeds(currentLocation: coordinate)

        if HMACrimeData.hasData() { return }

        // crime API
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
    class func fetch(minimumCoordinate minimumCoordinate: CLLocationCoordinate2D, maximumCoordinate: CLLocationCoordinate2D) -> Array<HMACrimeData> {
        let context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
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
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)

        // return crimes
        var error: NSError? = nil
        let crimeDatas: [AnyObject]?
        do {
            crimeDatas = try context.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            crimeDatas = nil
        }
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
    class func fetch(location location: CLLocation, radius: Double) -> Array<HMACrimeData> {
        let context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
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
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicaets)

        // return crimes
        var error: NSError? = nil
        let crimes: [AnyObject]?
        do {
            crimes = try context.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            crimes = nil
        }
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
    class func save(json json: JSON) {
        if HMACrimeData.hasData() { return }

        HMACrimeData.delete()

        let crimeDatas: Array<JSON> = json["crime_datas"].arrayValue
        let context = HMACoreDataManager.sharedInstance.managedObjectContext

        let dateFormatter = NSDateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        for crimeData in crimeDatas {
            let yyyymmddhhmmssSSS = crimeData["timestamp"].stringValue
            let timestamp = dateFormatter.dateFromString(yyyymmddhhmmssSSS)
            if timestamp == nil { continue }

            let crime = NSEntityDescription.insertNewObjectForEntityForName("HMACrimeData", inManagedObjectContext: context) as! HMACrimeData
            crime.category = crimeData["category"].stringValue
            crime.desc = crimeData["desc"].stringValue
            crime.lat = crimeData["lat"].numberValue
            crime.long = crimeData["long"].numberValue
            crime.timestamp = timestamp!
        }

        //var error: NSError? = nil
        do {
            try context.save()
        }
        catch _ {
            return
        }

        //if error == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentYearMonth = dateFormatter.stringFromDate(NSDate())
            NSUserDefaults().setObject(currentYearMonth, forKey: HMAUserDefaults.CrimeYearMonth)
            NSUserDefaults().synchronize()
        //}
    }

    /**
     * delete all crimeDatas
     **/
    class func delete() {
        let context = HMACoreDataManager.sharedInstance.managedObjectContext

        // make fetch request
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("HMACrimeData", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20

        // get all crimes
        //let error: NSError? = nil
        var crimeDatas: [HMACrimeData]? = nil
        do {
            crimeDatas = try context.executeFetchRequest(fetchRequest) as? [HMACrimeData]
        }
        catch _ {
        }
        if /*error != nil || */crimeDatas == nil {
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
