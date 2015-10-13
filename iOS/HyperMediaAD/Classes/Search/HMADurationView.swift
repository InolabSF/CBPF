import UIKit


/// MARK: - HMADurationViewDelegate
protocol HMADurationViewDelegate {

    /**
     * called when view was tapped
     * @param durationView HMADurationView
     */
    func touchedUpInside(durationView durationView: HMADurationView)

    /**
     * called when view will show
     * @param durationView HMADurationView
     */
    func willShow(durationView durationView: HMADurationView)

    /**
     * called when view will hide
     * @param durationView HMADurationView
     */
    func willHide(durationView durationView: HMADurationView)

}


/// MARK: - HMADurationView
class HMADurationView: UIView {

    /// MARK: - property
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var activeButton: BFPaperButton!
    var delegate: HMADurationViewDelegate?


    /// MARK: - life cycle

    override func awakeFromNib() {
        super.awakeFromNib()

        self.activeButton.isRaised = false
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(button: UIButton) {
        if button == self.activeButton {
            if self.delegate != nil {
                self.delegate?.touchedUpInside(durationView: self)
            }
        }
    }


    /// MARK: - public api

    /**
     * design
     * @param parentView UIView
     **/
    func design(parentView parentView: UIView) {
        // frame
        self.frame = CGRectMake(0, -self.frame.size.height, parentView.frame.size.width, self.frame.size.height)

        // shadow
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.2
        let rect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y+1, self.bounds.size.width, self.bounds.size.height)
        self.layer.shadowPath = UIBezierPath(rect: rect).CGPath
    }

    /**
     * show
     * @param destinationString String
     * @param durationString String
     **/
    func show(destinationString destinationString: String, durationString: String) {
        self.destinationLabel.text = destinationString
        self.durationLabel.text = durationString

        if self.delegate != nil {
            self.delegate?.willShow(durationView: self)
        }

        UIView.animateWithDuration(
            0.35,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
            },
            completion: { [unowned self] finished in
            }
        )
    }

    /**
     * hide
     **/
    func hide() {
        self.destinationLabel.text = ""
        self.durationLabel.text = ""

        if self.delegate != nil {
            self.delegate?.willHide(durationView: self)
        }

        UIView.animateWithDuration(
            0.15,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height)
            },
            completion: { [unowned self] finished in
            }
        )
    }

}
