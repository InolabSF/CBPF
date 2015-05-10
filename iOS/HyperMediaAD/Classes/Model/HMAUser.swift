import Foundation


/// MARK: - HMAUser
class HMAUser: AnyObject {

    /// MARK: - property
    var userID: String!


    /// MARK: - class method
    /**
     * return currentUser if user registration didn't finish, return nil
     * @return currentUser or nil
     */
    class func currentUser() -> HMAUser? {
        var user = HMAUser()

        let userDefaults = NSUserDefaults(suiteName: "group.org.kenzan8000.HyperMediaAD")!
        user.userID = userDefaults.stringForKey("user_id")

        if user.userID == nil { return nil }

        return user
    }


    /**
     * register user to server and local
     */
    class func register() {
        // confirm user
        let userDefaults = NSUserDefaults(suiteName: "group.org.kenzan8000.HyperMediaAD")!
        let userID = userDefaults.stringForKey("user_id")
        if userID != nil {
            HMALOG(String(format: "user_id = %@", userID!))
            return
        }

        // make post json
        let POSTJSONDictionary = ["sex":"1", "birthday":"Thu, 10 Apr 1986 22:15:29 GMT", "country":"America"];
        var POSTJSONData: NSData!
        if NSJSONSerialization.isValidJSONObject(POSTJSONDictionary) {
            POSTJSONData = NSJSONSerialization.dataWithJSONObject(POSTJSONDictionary, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        }
        if POSTJSONData == nil { return }

        // register
        var request = NSMutableURLRequest(URL: NSURL(string: "https://hypermediaad.herokuapp.com/user")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = POSTJSONData
        ISHTTPOperation.sendRequest(request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
            let responseJSON = JSON(data: object as! NSData)
            if let newUserID = responseJSON["user_id"].string {
                userDefaults.setObject(newUserID, forKey: "user_id")
                userDefaults.synchronize();
            }
        })

    }
}
