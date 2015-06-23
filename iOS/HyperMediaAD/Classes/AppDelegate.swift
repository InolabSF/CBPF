import UIKit
import Foundation
import HealthKit


/// MARK: - AppDelegate
class AppDelegate: UIResponder, UIApplicationDelegate, GMBLPlaceManagerDelegate {

    /// MARK: - property
    var window: UIWindow?
    var placeManager: GMBLPlaceManager!


    /// MARK: - life cycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Google Map
        GMSServices.provideAPIKey(HMAGoogleMap.APIKey)
        GMSServices.sharedServices()

        // UI setting
        (application as! QTouchposeApplication).alwaysShowTouches = true
        (application as! QTouchposeApplication).touchEndAnimationDuration = 0.50

        // Yelp
        HMAYelpCategory.create()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        HMACrimeData.requestToGetCrimeData()
        HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Humidity)
        HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Temperature)
    }

    func applicationWillTerminate(application: UIApplication) {
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    }
}
