import UIKit


/// MARK: - HMAYelpSemiModalViewDelegate
protocol HMAYelpSemiModalViewDelegate {

    /**
     * did decide search word for yelp search
     * @param semiModalView HMAYelpSemiModalView
     * @param searchWord search word for yelp search
     **/
    func semiModalView(semiModalView: HMAYelpSemiModalView, didDecideSearchWord searchWord: String);

}


/// MARK: - HMAYelpSemiModalView
class HMAYelpSemiModalView: UIView {

    /// MARK: - property

    var delegate: HMAYelpSemiModalViewDelegate?

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentBackgroundView: UIView!

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var buttonsScrollView: UIScrollView!


    /// MARK: - life cycle

    override func awakeFromNib()
    {
        super.awakeFromNib()

        // set scrollview contentSize
        var maxX: CGFloat = 0.0
        for button in self.buttons {
            var x = button.frame.origin.x + button.frame.size.width
            if maxX < x { maxX = x }
        }
        self.buttonsScrollView.contentSize = CGSizeMake(maxX, self.buttonsScrollView.frame.size.height)

        // buttons
        for var i = 0; i < self.buttons.count; i++ {
            self.buttons[i].setTitle("", forState: .Normal)
            var name = (HMAYelp.Categories[i] == "") ? "button_yelp_category" : "button_yelp_category_" + HMAYelp.Categories[i]
            self.buttons[i].setImage(UIImage(named: name), forState: .Normal)
        }

        // labels
        for var i = 0; i < self.labels.count; i++ {
            var text = (HMAYelp.Categories[i] == "") ? "yelp" : HMAYelp.Categories[i]
            self.labels[i].text = text
        }
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)

        for touch: AnyObject in touches {
            let point = (touch as! UITouch).locationInView(self)
            if CGRectContainsPoint(self.contentBackgroundView.frame, point) == false { // dismiss
                self.dismiss()
                break
            }
        }
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(#button: UIButton) {
        var index = 0
        for var i = 0; i < self.buttons.count; i++ {
            if button == self.buttons[i] {
                index = i
                break
            }
        }
        let searchWord = self.labels[index].text
        if self.delegate != nil && searchWord != nil {
            self.delegate?.semiModalView(self, didDecideSearchWord: searchWord!)
        }
        self.dismiss()
    }


    /// MARK: - public api

    /**
     * present view
     * @param parentView parentView
     **/
    func present(#parentView: UIView) {
        parentView.addSubview(self)
        self.frame = parentView.frame

        // animation
        let rect = self.contentBackgroundView.frame
        self.contentBackgroundView.frame = CGRectMake(self.contentBackgroundView.frame.origin.x, self.frame.size.height, self.contentBackgroundView.frame.size.width, self.contentBackgroundView.frame.size.height)
        self.backgroundView.alpha = 0.0
        UIView.animateWithDuration(
            0.25,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.contentBackgroundView.frame = rect
                self.backgroundView.alpha = 1.0
            },
            completion: { [unowned self] finished in
                // shadow
                self.contentBackgroundView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
                self.contentBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor
                self.contentBackgroundView.layer.shadowOpacity = 0.2
                self.contentBackgroundView.layer.shadowPath = UIBezierPath(rect: self.contentBackgroundView.bounds).CGPath
            }
        )
    }


    /// MARK: - private api

    /**
     * dismiss view
     **/
    private func dismiss() {
        // animation
        let rect = CGRectMake(self.contentBackgroundView.frame.origin.x, self.frame.size.height, self.contentBackgroundView.frame.size.width, self.contentBackgroundView.frame.size.height)
        UIView.animateWithDuration(
            0.15,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.contentBackgroundView.frame = rect
                self.backgroundView.alpha = 0.0
            },
            completion: { [unowned self] finished in
                self.removeFromSuperview()
            }
        )

    }

}


/// MARK: - UIViewController+HMAYelpSemiModalView
extension UIViewController {

    /// MARK: - public api

    /**
     * modal HMAYelpSemiModalView on self.view
     * @param modalView HMAYelpSemiModalView
     **/
    func presentModalView(modalView: HMAYelpSemiModalView) {
        modalView.present(parentView: self.view)
    }

}
