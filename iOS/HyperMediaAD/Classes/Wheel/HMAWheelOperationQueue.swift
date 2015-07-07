/// MARK: - HMAWheelOperationQueue
class HMAWheelOperationQueue: ISHTTPOperationQueue {

    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }

}
