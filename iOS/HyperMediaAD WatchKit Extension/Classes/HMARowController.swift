import WatchKit
import Foundation


/// MARK: - HMARowController
class HMARowController: NSObject {

    /// MARK: - property
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var descriptionLabel: WKInterfaceLabel!


    /// MARK: - public api
    func setSale(sale: HMASale) {
        self.titleLabel.setText(sale.title)
        self.descriptionLabel.setText(sale.desc)
    }
}
