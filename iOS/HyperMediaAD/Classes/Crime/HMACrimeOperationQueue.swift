/// MARK: - HMACrimeOperationQueue
class HMACrimeOperationQueue: ISHTTPOperationQueue {

    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }

}
