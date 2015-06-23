import Foundation


/// MARK: - HMAWheelClient
class HMAWheelClient: AnyObject {

    /// MARK: - property

    /// MARK: - class method

    static let sharedInstance = HMAWheelClient()


    /// MARK: - public api

    /**
     * POST /wheel/data
     * @param wheelDatas hash
     *  {
     *    "wheel_datas": [
     *      {
     *        "data_type": 9,
     *        "lat": 37.76681832250885,
     *        "long": -122.4207906162038,
     *        "user_id": 1,
     *        "timestamp": "2015-05-07T01:25:39.738Z",
     *        "value": 13.555334
     *      },
     *      ...
     *    ]
     *  }
     * @param completionHandler (json: JSON) -> Void
     */
    func postWheelData(
        #wheelDatas: Dictionary<String, Array<Dictionary<String, AnyObject>>>,
        completionHandler: (json: JSON) -> Void
    ) {
        // make request
        var request = NSMutableURLRequest(URL: NSURL(string: HMAWheel.API.Data)!)
        request.HTTPMethod = "POST"
        request.hma_setHTTPBody(dictionary: wheelDatas)

        // request
        ISHTTPOperation.sendRequest(request, handler:{ (response: NSHTTPURLResponse!, object: AnyObject!, error: NSError!) -> Void in
                if error != nil { return }

                var responseJSON = JSON([:])
                if object != nil { responseJSON = JSON(data: object as! NSData) }
                else { return }
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            }
        )
    }

}
