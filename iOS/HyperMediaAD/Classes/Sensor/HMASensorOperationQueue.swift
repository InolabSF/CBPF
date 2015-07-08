private let _HMASensorOperationQueueDefaultQueue = HMASensorOperationQueue.defaultQueue()

/// MARK: - HMASensorOperationQueue
class HMASensorOperationQueue: ISHTTPOperationQueue {

    class var sharedInstance: HMASensorOperationQueue {
        _HMASensorOperationQueueDefaultQueue.maxConcurrentOperationCount = 1
        return _HMASensorOperationQueueDefaultQueue
    }

    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }

}
