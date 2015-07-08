private let _HMACrimeOperationQueueDefaultQueue = HMACrimeOperationQueue.defaultQueue()

/// MARK: - HMACrimeOperationQueue
class HMACrimeOperationQueue: ISHTTPOperationQueue {

    class var sharedInstance: HMACrimeOperationQueue {
        _HMACrimeOperationQueueDefaultQueue.maxConcurrentOperationCount = 1
        return _HMACrimeOperationQueueDefaultQueue
    }

    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }

}
