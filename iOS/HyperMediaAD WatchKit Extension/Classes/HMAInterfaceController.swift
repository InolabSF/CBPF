import WatchKit
import Foundation


/// MARK: - HMAInterfaceController
class HMAInterfaceController: WKInterfaceController {

    /// MARK: - property
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    var sales: [HMASale]! = []


    /// MARK: - life cycle
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        super.willActivate()

        self.reloadTable()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        /// remote notification
    }

    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        /// local notification
        self.reloadTable()
    }

    override func handleUserActivity(userInfo: [NSObject : AnyObject]?) {
        /// glance
    }


    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return self.sales[rowIndex]
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    }


    /// MARK: - public api
    func reloadTable() {
        let userDefaults = NSUserDefaults(suiteName: "group.org.kenzan8000.HyperMediaAD")!
        let currentADs = userDefaults.arrayForKey("MediaLocalADs") as [AnyObject]!
        if currentADs == nil { return }

        self.sales.removeAll()
        for var i = 0; i < currentADs.count; i++ {
            let sale = HMASale(JSON: currentADs[i] as! NSDictionary)
            self.sales.append(sale)
        }
        self.interfaceTable.setNumberOfRows(self.sales.count, withRowType: "default")

        for var i = 0; i < self.sales.count; i++ {
            if var row = self.interfaceTable.rowControllerAtIndex(i) as? HMARowController {
                row.setSale(self.sales[i])
            }
        }
    }


}
