import Foundation


/// MARK: - HMAYelpClient
class HMAYelpClient: AnyObject {

    /// MARK: - property

    /// MARK: - class method

    static let sharedInstance = HMAYelpClient()


    /// MARK: - public api

    /**
     * GET http://www.yelp.com/developers/documentation/v2/search_api
     * @param term search word (String)
     * @param completionHandler (json: JSON) -> Void
     */
    func getSearchResult(
        #term: String,
        completionHandler: (json: JSON) -> Void
    ) {
        var manager = HMAAuth1RequestOperationManager(
            consumerKey: HMAYelp.ConsumerKey,
            consumerSecret: HMAYelp.ConsumerSecret,
            accessToken: HMAYelp.AccessToken,
            accessSecret: HMAYelp.AccessSecret
        )
        manager.searchWithTerm(
            term,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                //println(JSON(response))
                var responseJSON = JSON([:])
                if response != nil { responseJSON = JSON(response) }

                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler(json: responseJSON)
                })
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            }
        )
    }
}


/// MARK: - HMAAuth1RequestOperationManager
class HMAAuth1RequestOperationManager: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!

    required init(coder adecoder: NSCoder) {
        super.init(coder: adecoder)
    }

    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        var baseUrl = NSURL(string: "http://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);

        var token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }

    func searchWithTerm(term: String, success: (AFHTTPRequestOperation!, AnyObject!) -> Void, failure: (AFHTTPRequestOperation!, NSError!) -> Void) -> AFHTTPRequestOperation! {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        var parameters = ["term": term, "location": "San Francisco"]
        return self.GET("search", parameters: parameters, success: success, failure: failure)
    }
}
