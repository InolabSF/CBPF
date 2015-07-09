import UIKit


/// MARK: - HMATestTableViewCell
class HMATestTableViewCell: UITableViewCell {

    /// MARK: - property

    @IBOutlet weak private var titleLabel: UILabel!


    /// MARK: - class method

    class func hma_height() -> CGFloat {
        return 54.0
    }

    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener


    /// MARK: - public api

    /**
     * design
     * @param title String
     **/
    func design(#title: String) {
        self.titleLabel.text = title
    }

}

