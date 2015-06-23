import UIKit


/// MARK: - HMABottomButtonDelegate
protocol HMABottomButtonDelegate {

    /**
     * called when clicked
     * @param bottomButton HMABottomButton
     */
    func bottomButtonWasClicked(#bottomButton: HMABottomButton)

}


/// MARK: - HMABottomButton
class HMABottomButton: UIView {

    /// MARK: - property

    var delegate: HMABottomButtonDelegate?

    @IBOutlet weak var button: UIButton!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(#button: UIButton) {
        if button == self.button {
            // delegate
            if self.delegate != nil { self.delegate?.bottomButtonWasClicked(bottomButton: self) }
        }
    }


    /// MARK: - public api

    /**
     * design
     */
    func design() {
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.2
        var rect = self.bounds
        self.layer.shadowPath = UIBezierPath(rect: rect).CGPath
    }


}
