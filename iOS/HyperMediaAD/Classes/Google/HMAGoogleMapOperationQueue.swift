private let _HMAGoogleMapOperationQueueDefaultQueue = HMAGoogleMapOperationQueue.defaultQueue()

/// MARK: - HMAGoogleMapOperationQueue
class HMAGoogleMapOperationQueue: ISHTTPOperationQueue {

    class var sharedInstance: HMAGoogleMapOperationQueue {
        _HMAGoogleMapOperationQueueDefaultQueue.maxConcurrentOperationCount = 1
        return _HMAGoogleMapOperationQueueDefaultQueue
    }

    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }

}
