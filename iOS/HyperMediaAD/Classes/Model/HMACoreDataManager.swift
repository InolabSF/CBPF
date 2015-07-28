import CoreData


/// MARK: - HMACoreDataManager
class HMACoreDataManager {

    /// MARK: - class method
    static let sharedInstance = HMACoreDataManager()

    /// MARK: - property

    var managedObjectModel: NSManagedObjectModel {
        let modelURL = NSBundle.mainBundle().URLForResource("HMAModel", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }

    var managedObjectContext: NSManagedObjectContext {
        var coordinator = self.persistentStoreCoordinator

        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }

    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = documentsDirectories[documentsDirectories.count - 1] as! NSURL
        let storeURL = documentsDirectory.URLByAppendingPathComponent("HMAModel.sqlite")

        var error: NSError? = nil
        var persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        persistentStoreCoordinator.addPersistentStoreWithType(
            NSSQLiteStoreType,
            configuration: nil,
            URL: storeURL,
            options: nil,
            error: &error
        )

        return persistentStoreCoordinator
    }


    /// MARK: - initialization
    init() {
    }


    /// MARK: - public class method

    /**
     * delete all data if delete needs
     * @param currentLocation currentLocation
     **/
    class func deleteAllDataIfNeeds(#currentLocation: CLLocationCoordinate2D) {
        if HMACoreDataManager.isTooFarFromLastLocation(currentLocation: currentLocation) {
            HMACrimeData.delete()
            HMASensorData.delete()
            HMAHeatIndexData.delete()
            HMAWheelData.delete()

            HMACoreDataManager.setDataLocation(currentLocation)
        }
    }


    /// MARK: - private class method

    /**
     * check if delete needs
     * @param currentLocation currentLocation
     * @return true or false
     **/
    private class func isTooFarFromLastLocation(#currentLocation: CLLocationCoordinate2D) -> Bool {
        let lastLatitude = NSUserDefaults().doubleForKey(HMAUserDefaults.LastLatitude)
        let lastLongitude = NSUserDefaults().doubleForKey(HMAUserDefaults.LastLongitude)

        let distance = HMAMapMath.miles(
            locationA: CLLocation(latitude: lastLatitude, longitude: lastLongitude),
            locationB: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        )
        return (Float(distance) > HMAAPI.RenewDistance)
    }

    /**
     * set location that gets data
     * @param currentLocation currentLocation
     **/
    private class func setDataLocation(location: CLLocationCoordinate2D) {
        NSUserDefaults().setDouble(location.latitude, forKey: HMAUserDefaults.LastLatitude)
        NSUserDefaults().setDouble(location.longitude, forKey: HMAUserDefaults.LastLongitude)
        NSUserDefaults().synchronize()
    }

}
