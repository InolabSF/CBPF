import UIKit


/// MARK: - HMACircleButtonDelegate
protocol HMACircleButtonDelegate {

    /**
     * called when check box was on
     * @param circleButton HMACircleButton
     * @param wasOn On or Off (Bool)
     */
    func circleButton(circleButton: HMACircleButton, wasOn: Bool)

}


/// MARK: - HMACircleButton
class HMACircleButton: UIView {

    /// MARK: - property

    var delegate: HMACircleButtonDelegate?

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonBackgroundView: UIView!


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        // rounded corner
        self.buttonBackgroundView.layer.cornerRadius = self.buttonBackgroundView.frame.size.width / 2.0
        self.buttonBackgroundView.layer.masksToBounds = true
        // rounded corner
        self.button.layer.cornerRadius = self.buttonBackgroundView.frame.size.width / 2.0
        self.button.layer.masksToBounds = true
        // border
        self.button.layer.borderColor = UIColor.grayColor().CGColor
        self.button.layer.borderWidth = 0.5
        self.button.clipsToBounds = true
/*
        self.buttonBackgroundView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.buttonBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor
        self.buttonBackgroundView.layer.shadowOpacity = 0.4
        let rect = CGRectMake(self.buttonBackgroundView.bounds.origin.x, self.buttonBackgroundView.bounds.origin.y + 2, self.buttonBackgroundView.bounds.size.width, self.buttonBackgroundView.bounds.size.height)
        self.buttonBackgroundView.layer.shadowPath = UIBezierPath(rect: rect).CGPath
*/
        self.setIsOn(false)
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(#button: UIButton) {
        if button == self.button {
            let isOn = (self.button.alpha < 0.8)
            self.setIsOn(isOn)

            // delegate
            if self.delegate != nil { self.delegate?.circleButton(self, wasOn: isOn) }
        }
    }


    /// MARK: - publc api

    /**
     * set button image
     * @param image image
     **/
    func setImage(image: UIImage) {
        self.button.setImage(image, forState: .Normal)
    }

    /**
     * toggle checkbox on and off
     * @param isOn Bool
     **/
    func setIsOn(isOn: Bool) {
        self.button.alpha = (isOn) ? 1.0 : 0.65
    }

}
