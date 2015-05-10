import WatchKit
import Foundation


/// MARK: - HMANotificationController
class HMANotificationController: WKUserNotificationInterfaceController {


    /// MARK: - initialization
    override init() {
        super.init()
    }


    /// MARK: - life cycle
    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        HMALOG("called didReceiveLocalNotification")
        //if identifier == "" {
        //}
        completionHandler(WKUserNotificationInterfaceType.Custom);
    }

    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        HMALOG("called didReceiveRemoteNotification")
       //if identifier == "" {
        //}
        completionHandler(WKUserNotificationInterfaceType.Custom);
    }
}
