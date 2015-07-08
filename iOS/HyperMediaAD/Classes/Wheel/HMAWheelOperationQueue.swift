private let _HMAWheelOperationQueueDefaultQueue = HMAWheelOperationQueue.defaultQueue()

/// MARK: - HMAWheelOperationQueue
class HMAWheelOperationQueue: ISHTTPOperationQueue {

    class var sharedInstance: HMAWheelOperationQueue {
        _HMAWheelOperationQueueDefaultQueue.maxConcurrentOperationCount = 1
        return _HMAWheelOperationQueueDefaultQueue
    }

    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }

}
