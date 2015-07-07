/// MARK: - HMAGoogleMapOperationQueue
class HMAGoogleMapOperationQueue: ISHTTPOperationQueue {

    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }

}
