/// MARK: - HMASensorOperationQueue
class HMASensorOperationQueue: ISHTTPOperationQueue {

    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1
    }

}
