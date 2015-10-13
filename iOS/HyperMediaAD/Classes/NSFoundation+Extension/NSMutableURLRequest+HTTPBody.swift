import Foundation


/// MARK: - NSMutableURLRequest+HTTPBody
extension NSMutableURLRequest {

    /// MARK: - public api

    /**
     * set httpbody
     * @param dictionary dictionary
     */
    func hma_setHTTPBody(dictionary dictionary: Dictionary<String, AnyObject>) {
        let json = JSON(dictionary)
        let body: NSData?
        do {
            body = try json.rawData()
        } catch _ {
            body = nil
        }

        self.HTTPBody = body
        if body != nil { self.setValue("\(body!.length)", forHTTPHeaderField:"Content-Length") }
    }


    /// MARK: - private api
}
