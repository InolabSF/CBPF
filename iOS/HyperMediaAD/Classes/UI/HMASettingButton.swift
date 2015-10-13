import UIKit


/// MARK: - HMASettingButtonDelegate
protocol HMASettingButtonDelegate {

    /**
     * called when button touchedUpInside
     * @param settingButton HMASettingButton
     */
    func settingButton(settingButton: HMASettingButton)

}


/// MARK: - HMASettingButton
class HMASettingButton: UIView {

    /// MARK: - property

    var delegate: HMASettingButtonDelegate?

    @IBOutlet weak var button: UIButton!
    //@IBOutlet weak var buttonBackgroundView: UIView!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()
/*
        // shadow
        self.buttonBackgroundView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.buttonBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor
        self.buttonBackgroundView.layer.shadowOpacity = 0.4
        let rect = CGRectMake(self.buttonBackgroundView.bounds.origin.x, self.buttonBackgroundView.bounds.origin.y + 2, self.buttonBackgroundView.bounds.size.width, self.buttonBackgroundView.bounds.size.height)
        self.buttonBackgroundView.layer.shadowPath = UIBezierPath(rect: rect).CGPath
*/
        self.button.setImage(IonIcons.imageWithIcon(ion_navicon_round, size: self.button.frame.size.width, color: UIColor.grayColor()), forState: .Normal)
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(button button: UIButton) {
        if self.delegate != nil { self.delegate?.settingButton(self) }
    }

}

