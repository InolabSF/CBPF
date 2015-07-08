import UIKit


/// MARK: - HMADrawerController
class HMADrawerController: KYDrawerController {

    static var sharedInstance: HMADrawerController!


    /// MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self.mainViewController as! HMAViewController
        HMADrawerController.sharedInstance = self
    }
}
