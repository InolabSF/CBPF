import UIKit


/// MARK: - HMASearchBoxViewDelegate
protocol HMASearchBoxViewDelegate {

    /**
     * called when search box was active
     * @param searchBoxView HMASearchBoxView
     */
    func searchBoxWasActive(searchBoxView searchBoxView: HMASearchBoxView)

    /**
     * called when search box was inactive
     * @param searchBoxView HMASearchBoxView
     */
    func searchBoxWasInactive(searchBoxView searchBoxView: HMASearchBoxView)

    /**
     * called when destination search finishes
     * @param searchBoxView HMASearchBoxView
     * @param destinations prediction of destinations
     */
    func searchDidFinish(searchBoxView searchBoxView: HMASearchBoxView, destinations: [HMADestination])

    /**
     * called when clear button is touched up inside
     * @param searchBoxView HMASearchBoxView
     */
    func clearButtonTouchedUpInside(searchBoxView searchBoxView: HMASearchBoxView)

    /**
     * called when geoLocation search did finish
     * @param searchBoxView HMASearchBoxView
     */
    func geoLocationSearchDidFinish(searchBoxView searchBoxView: HMASearchBoxView, coordinate: CLLocationCoordinate2D)
}


/// MARK: - HMASearchBoxView
class HMASearchBoxView: UIView {

    /// MARK: - property
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldBackgroundView: UIView!
    @IBOutlet weak var searchGeoLocationOverlayView: UIView!
    @IBOutlet weak var searchGeoLocationIndicator: TYMActivityIndicatorView!
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

        self.searchGeoLocationIndicator.hidesWhenStopped = true
        self.searchGeoLocationIndicator.stopAnimating()
    }


    /// MARK: - event listener

    @IBAction func touchedUpInside(button button: UIButton) {
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

            HMAGoogleMapClient.sharedInstance.cancelGetGeocode()
            self.searchGeoLocationIndicator.stopAnimating()
            self.searchGeoLocationOverlayView.hidden = true
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
            input: destination!,
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
    func design(parentView parentView: UIView) {
        self.frame = CGRectMake(0, 0, parentView.bounds.width, self.frame.size.height)

        self.searchTextFieldBackgroundView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.searchTextFieldBackgroundView.layer.shadowColor = UIColor.blackColor().CGColor
        self.searchTextFieldBackgroundView.layer.shadowOpacity = 0.2
        let rect = self.searchTextFieldBackgroundView.bounds
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

    /**
     * start geo location search
     * @param location CLLocationCoordinate2D
     **/
    func startSearchGeoLocation(coordinate coordinate: CLLocationCoordinate2D) {
        self.searchGeoLocationOverlayView.hidden = false
        self.searchGeoLocationIndicator.activityIndicatorViewStyle = TYMActivityIndicatorViewStyle.Small
        self.searchGeoLocationIndicator.setBackgroundImage(
            UIImage(named: "clear.png"),
            forActivityIndicatorStyle:TYMActivityIndicatorViewStyle.Small
        )

        self.searchGeoLocationIndicator.startAnimating()
        HMAGoogleMapClient.sharedInstance.getGeocode(
            address: self.searchTextField.text!,
             radius: Double(HMAAPI.Radius),
           location: coordinate,
  completionHandler: { [unowned self] (json) in
                let destination = self.geoLocations(json: json)
                let succeeded = (destination != nil && self.delegate != nil)
                if succeeded {
                    self.clearButton.hidden = true
                    self.delegate?.geoLocationSearchDidFinish(searchBoxView: self, coordinate: destination!)
                    self.searchTextField.text = ""
                }
                self.searchGeoLocationIndicator.stopAnimating()
                self.searchGeoLocationOverlayView.hidden = true
            }
        )
    }

    /**
     * show
     **/
    func show() {
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


    /// MARK: - private api

    /**
     * return geo location
     * @param json json
     * @return CLLocationCoordinate2D
     **/
    private func geoLocations(json json: JSON) -> CLLocationCoordinate2D? {
        let results = json["results"].arrayValue
        if results.count == 0 { return nil }

        let result = results[0].dictionaryValue
        let geometry = result["geometry"]!.dictionaryValue
        if let locationDictionary = geometry["location"]!.dictionary {
            return CLLocationCoordinate2D(latitude: locationDictionary["lat"]!.doubleValue, longitude: locationDictionary["lng"]!.doubleValue)
        }

        return nil
    }

}


/// MARK: - UITextFieldDelegate
extension HMASearchBoxView: UITextFieldDelegate {
}
