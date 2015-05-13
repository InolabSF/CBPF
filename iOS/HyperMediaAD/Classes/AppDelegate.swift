import UIKit
import Foundation
import HealthKit


/// MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GMBLPlaceManagerDelegate {

    /// MARK: - property
    var window: UIWindow?
    var placeManager: GMBLPlaceManager!


    /// MARK: - life cycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // Mapbox
        RMConfiguration.sharedInstance().accessToken = kMapboxAccessToken

        // Google Map
        //GMSServices.provideAPIKey(kGoogleMapAPIKey)
        //GMSServices.sharedServices()

        // Gimbal
        Gimbal.setAPIKey(kGimbalAPIKey, options:nil)
        self.placeManager = GMBLPlaceManager()
        self.placeManager.delegate = self
        GMBLPlaceManager.startMonitoring()
        HMALOG(String(format: "GMBLPlaceManager.isMonitoring %@", GMBLPlaceManager.isMonitoring()))

        // register user
        //if HMAUser.currentUser() == nil { HMAUser.register() }

        // background fetch
        //UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }
/*
    func application(application: UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData!) {
        HMALOG("Caught remote notification")
    }
*/
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        HMALOG("Caught local notification")
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        self.checkDistance(performFetchWithCompletionHandler: completionHandler)
    }


    /// MARK: - private api

    /**
     * get yelp data
     * @param titleString title
     * @param bodyString body
     */
    func searchYelp(title titleString: String, body bodyString: String) {
        // yelp
        var client = HMAYelpClient(
            consumerKey: "aEgsqiXtod6euKrDE3K7UQ",
            consumerSecret: "26Yr5oBbPkcdOnvb_j1UvoFJe1M",
            accessToken: "1PC6SGoDEAXIQiojPiTJn48zCsbT8Sm9",
            accessSecret: "TIze7QMF6i_szxvwaXAobv9wXLo"
        )
        client.searchWithTerm(
            titleString,
            success: { [unowned self] (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                //HMALOG(String(format: "%@", response as! NSDictionary))

                self.updateCurrentAD(response: response as! NSDictionary, title: titleString, body: bodyString)
                self.postLocalNotification(title: titleString, body: bodyString)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                HMALOG(String(format: "%@", error))
            }
        )
    }

    /**
     * update currenAD
     * @param response response from yelp
     * @param titleString title
     * @param bodyString body
     */
    func updateCurrentAD(response yelpResponse: NSDictionary, title titleString: String, body bodyString: String) {
        // save ADs
        var newAD = NSMutableDictionary()
        newAD.setObject(titleString, forKey:"title")
        newAD.setObject(bodyString, forKey:"description")
        newAD.setObject(yelpResponse.objectForKey("businesses")?.objectAtIndex(0).objectForKey("name") as! NSString, forKey:"name")
        newAD.setObject(yelpResponse.objectForKey("businesses")?.objectAtIndex(0).objectForKey("image_url") as! NSString, forKey:"image_url")
        newAD.setObject(yelpResponse.objectForKey("businesses")?.objectAtIndex(0).objectForKey("rating") as! Int, forKey:"rating")
        newAD.setObject(yelpResponse.objectForKey("businesses")?.objectAtIndex(0).objectForKey("location")?.objectForKey("coordinate") as! NSDictionary, forKey:"coordinate")
        newAD.setObject(yelpResponse.objectForKey("businesses")?.objectAtIndex(0).objectForKey("display_phone") as! NSString, forKey:"display_phone")

        let userDefaults = NSUserDefaults(suiteName: "group.org.kenzan8000.HyperMediaAD")!
        let currentADs = userDefaults.arrayForKey("MediaLocalADs") as [AnyObject]?
        var newADs = NSMutableArray()
        if currentADs != nil { newADs.addObjectsFromArray(currentADs!) }
        newADs.addObject(newAD)

        userDefaults.setObject(newADs, forKey: "MediaLocalADs")
        userDefaults.synchronize()
    }

    /**
     * post local notification
     * @param titleString title
     * @param bodyString body
     */
    func postLocalNotification(title titleString: String, body bodyString: String) {
        // local notification
        if UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:")) {
            var localNotification:UILocalNotification = UILocalNotification()
            localNotification.alertAction = "Testing notifications on iOS8"
            localNotification.alertTitle = titleString
            localNotification.alertBody = bodyString
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 2)

            let types = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }

    /**
     * check walk or running, cycling distance from health kit
     * @param performFetchWithCompletionHandler
     */
    func checkDistance(performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        // health kit isn't available
        if !(HKHealthStore.isHealthDataAvailable()) { return }

        var healthStore = HKHealthStore()
        let shareObjectTypes = NSSet(array: [])
        let readObjectTypes = NSSet(array: [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling),
        ])

        healthStore.requestAuthorizationToShareTypes(
            shareObjectTypes as Set<NSObject>,
            readTypes: readObjectTypes as Set<NSObject>,
            completion: { (success: Bool, error: NSError!) in

            if !success { return }

            let kIntervalMinutes = 30
            let kIntervalMeters = 1000.0

            let endDate = NSDate()
            let startDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitMinute, value: -kIntervalMinutes, toDate: endDate, options: nil)!
            let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: nil)
            let intervalComponents = NSDateComponents()
            intervalComponents.minute = kIntervalMinutes

            let query = HKStatisticsCollectionQuery(
                quantityType: HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
                quantitySamplePredicate: predicate,
                options: HKStatisticsOptions.CumulativeSum,
                anchorDate: endDate,
                intervalComponents: intervalComponents
            )
            query.initialResultsHandler = {(query, results, error) -> Void in
                let statistics = results.statistics() as! [HKStatistics]
                for statistic in statistics {
                    let distance = statistic.sumQuantity().doubleValueForUnit(HKUnit(fromString: "m"))
                    // walk more than kIntervalMeters meters for kIntervalMinutes minutes
                    if distance < kIntervalMeters { continue }
                    HMALOG("You must have been tired!")
                }
                completionHandler(UIBackgroundFetchResult.NewData)
            }
            healthStore.executeQuery(query)
        })

    }

}


/// MARK: - GMBLPlaceManagerDelegate
extension AppDelegate: GMBLPlaceManagerDelegate {

    func placeManager(manager: GMBLPlaceManager,  didBeginVisit visit: GMBLVisit) {
        let beacon_identifier = (visit.place as GMBLPlace).identifier
        HMALOG(String(format: "place name: %@", (visit.place as GMBLPlace).name))
        HMALOG(String(format: "place identifier: %@", beacon_identifier))

        let user = HMAUser.currentUser()
        if user == nil { return }

        // check if there is an event that matches user profile
        let URLString = String(format: "https://hypermediaad.herokuapp.com/event?beacon_identifier=%@&user_id=%@", beacon_identifier, user!.userID!)
        let request = NSMutableURLRequest(URL: NSURL(string: URLString)!)
        ISHTTPOperation.sendRequest(request, handler:{ [unowned self] (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                let responseJSON = JSON(data: object as! NSData)
                let title: AnyObject? = responseJSON["title"].string
                let description: AnyObject? = responseJSON["description"].string
                if title != nil && description != nil {
                    self.searchYelp(title: title as! String, body: description as! String)
                }
            }
        )
    }

    func placeManager(manager: GMBLPlaceManager, didEndVisit visit: GMBLVisit) {
    }

/*
    func placeManager(manager: GMBLPlaceManager, didReceiveBeaconSighting sighting: GMBLBeaconSighting, forVisits visits: NSArray) {
    }
*/
}


        // test
/*
        // sample data
        let jsonString = "{\"businesses\":[{\"name\":\"SuperDuperBurgers\",\"image_url\":\"http://s3-media3.fl.yelpassets.com/bphoto/CgZ2z_UtHjb_RBUDJjHa2w/ms.jpg\",\"location\":{\"coordinate\":{\"latitude\":\"37.786856\",\"longitude\":\"-122.403905\"}},\"display_phone\":\"+1-415-538-3437\",\"rating\":4}]}"
        var JSON = NSJSONSerialization.JSONObjectWithData(
            jsonString.dataUsingEncoding(NSUTF8StringEncoding)!,
            options: NSJSONReadingOptions.AllowFragments,
            error: nil
        ) as! NSDictionary
        self.updateCurrentAD(response: JSON, title: "Super Duper", body: "Fast Food Burgers...Slow Food Values")

        // check distance
        self.checkDistance(performFetchWithCompletionHandler: {(UIBackgroundFetchResult) -> Void in })
*/

