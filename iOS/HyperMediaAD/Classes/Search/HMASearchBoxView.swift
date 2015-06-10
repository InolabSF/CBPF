import UIKit


/// MARK: - HMASearchBoxViewDelegate
protocol HMASearchBoxViewDelegate {

    /**
     * called when search box was active
     * @param searchBoxView HMASearchBoxView
     */
    func searchBoxWasActive(#searchBoxView: HMASearchBoxView)

    /**
     * called when search box was inactive
     * @param searchBoxView HMASearchBoxView
     */
    func searchBoxWasInactive(#searchBoxView: HMASearchBoxView)

    /**
     * called when destination search finishes
     * @param searchBoxView HMASearchBoxView
     * @param destinations prediction of destinations
     */
    func searchDidFinish(#searchBoxView: HMASearchBoxView, destinations: [HMADestination])

    /**
     * called when clear button is touched up inside
     * @param searchBoxView HMASearchBoxView
     */
    func clearButtonTouchedUpInside(#searchBoxView: HMASearchBoxView)

}


/// MARK: - HMASearchBoxView
class HMASearchBoxView: UIView {

    /// MARK: - property
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldBackgroundView: UIView!
    @IBOutlet weak var activeButton: BFPaperButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    var delegate: HMASearchBoxViewDelegate?
    var isActive: Bool {
        return self.activeButton.hidden
    }


    /// MARK: - life cycle

    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.searchTextField.addTarget(self, action: Selector("didChangeTextField:"), forControlEvents: .EditingChanged)
        self.activeButton.isRaised = false
        self.clearButton.hidden = true

        let backImage = IonIcons.imageWithIcon(
            ion_arrow_left_c,
            size: 20.0,
            color: UIColor.grayColor()
        )
        self.backButton.setImage(backImage, forState: .Normal)

        let closeImage = IonIcons.imageWithIcon(
            ion_ios_close_empty,
            size: 36.0,
            color: UIColor.grayColor()
        )
        self.clearButton.setImage(closeImage, forState: .Normal)
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(#button: UIButton) {
        if button == self.activeButton {
            self.startSearch()
        }
        else if button == self.backButton {
            self.endSearch()
        }
        else if button == self.clearButton {
            self.searchTextField.text = ""
            self.clearButton.hidden = true
            if self.delegate != nil {
                self.delegate?.clearButtonTouchedUpInside(searchBoxView: self)
                self.delegate?.searchDidFinish(searchBoxView: self, destinations: [] as [HMADestination])
            }
        }
    }

    func didChangeTextField(textField: UITextField) {
        let destination = textField.text
        if destination == nil || destination == "" {
            self.clearButton.hidden = true
            if self.delegate != nil {
                self.delegate?.searchDidFinish(searchBoxView: self, destinations: [] as [HMADestination])
            }
            return
        }
        self.clearButton.hidden = false

        let location = HMAMapView.sharedInstance.myLocation
        if location == nil { return }

        HMAGoogleMapClient.sharedInstance.cancelGetPlaceAutoComplete()

        // place autocomplete API
        HMAGoogleMapClient.sharedInstance.getPlaceAutoComplete(
            input: destination,
            radius: 5,
            location: location.coordinate,
            completionHandler: { [unowned self] (json) in
                let destinations = HMADestination.destinations(json: json)
                if self.delegate != nil {
                    self.delegate?.searchDidFinish(searchBoxView: self, destinations: destinations)
                }
            }
        )
    }


    /// MARK: - public api

    /**
     * design
     * @param parentView parent view
     */
    func design(#parentView: UIView) {
        self.frame = CGRectMake(0, 20, parentView.bounds.width, self.frame.size.height)

        self.searchTextFieldBackgroundView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.searchTextFieldBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor
        self.searchTextFieldBackgroundView.layer.shadowOpacity = 0.2
        var rect = self.searchTextFieldBackgroundView.bounds
        self.searchTextFieldBackgroundView.layer.shadowPath = UIBezierPath(rect: rect).CGPath
    }

    /**
     * set searchText to textField
     * @param searchText searchText
     **/
    func setSearchText(searchText: String) {
        self.searchTextField.text =  searchText
        self.clearButton.hidden = (self.searchTextField.text == nil || self.searchTextField.text == "")
    }

    /**
     * start searching
     **/
    func startSearch() {
        self.searchTextField.becomeFirstResponder()
        self.activeButton.hidden = true
        self.backButton.hidden = false
        if self.delegate != nil { self.delegate?.searchBoxWasActive(searchBoxView: self) }
        self.clearButton.hidden = (self.searchTextField.text == nil || self.searchTextField.text == "")
    }

    /**
     * end searching
     **/
    func endSearch() {
        self.searchTextField.resignFirstResponder()
        self.activeButton.hidden = false
        self.backButton.hidden = true
        if self.delegate != nil { self.delegate?.searchBoxWasInactive(searchBoxView: self) }
        self.clearButton.hidden = (self.searchTextField.text == nil || self.searchTextField.text == "")
    }

}


/// MARK: - UITextFieldDelegate
extension HMASearchBoxView: UITextFieldDelegate {
}
