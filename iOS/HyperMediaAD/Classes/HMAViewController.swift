import UIKit
import CoreLocation


/// MARK: - HMAViewController
class HMAViewController: UIViewController, CLLocationManagerDelegate {

    /// MARK: - property
    var locationManager: CLLocationManager!

    /// UserInterface mode
    var userInterfaceMode = HMAUserInterface.Mode.SetDestinations
    /// MapView
    var mapView: HMAMapView!

    /// setting button
    private var settingButton: HMASettingButton!
    /// next button
    @IBOutlet weak var nextButton: HMANextButton!
    /// crime button
    private var crimeButton: HMACircleButton!
    /// heatindex button
    private var comfortButton: HMACircleButton!
    /// wheel button
    private var wheelButton: HMACircleButton!
    /// view to show duration
    private var durationView: HMADurationView!
    /// search box
    private var searchBoxView: HMASearchBoxView!
    /// search result
    private var searchResultView: HMASearchResultView!


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()


        let rect = UIScreen.mainScreen().bounds

        // notification
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("changeUserInterfaceMode:"),
            name: HMANotificationCenter.ChangeUserInterfaceMode,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("GoToTheLocation:"),
            name: HMANotificationCenter.GoToTheLocation,
            object: nil
        )

        // google map view
        self.mapView = HMAMapView.sharedInstance
        self.mapView.frame = rect
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        self.mapView.doSettings()
        self.mapView.setUserInterfaceMode(self.userInterfaceMode)
        self.mapView.camera = GMSCameraPosition.cameraWithLatitude(
            HMAGoogleMap.Latitude,
            longitude: HMAGoogleMap.Longitude,
            zoom: HMAGoogleMap.Zoom.Default
        )

        // next button
        self.nextButton.design()
        self.view.bringSubviewToFront(self.nextButton)

        // circle button
        var circleButtons: [HMACircleButton] = []
        let circleButtonImages = [UIImage(named: "button_crime")!, UIImage(named: "button_comfort")!, UIImage(named: "button_wheel")!]
        for var i = 0; i < circleButtonImages.count; i++ {
            let circleButtonNib = UINib(nibName: HMANSStringFromClass(HMACircleButton), bundle:nil)
            let circleButtonViews = circleButtonNib.instantiateWithOwner(nil, options: nil)
            let circleButtonView = circleButtonViews[0] as! HMACircleButton
            circleButtonView.frame = CGRectMake(
                rect.size.width - circleButtonView.frame.size.width - 10.0,
                rect.size.height - (circleButtonView.frame.size.height + 10.0) * CGFloat(i+2),
                circleButtonView.frame.size.width,
                circleButtonView.frame.size.height
            )
            circleButtonView.setImage(circleButtonImages[i])
            self.view.addSubview(circleButtonView)
            circleButtonView.delegate = self

            circleButtons.append(circleButtonView)
        }
        self.crimeButton = circleButtons[0]
        self.comfortButton = circleButtons[1]
        self.wheelButton = circleButtons[2]

        // search result
        let searchResultNib = UINib(nibName: HMANSStringFromClass(HMASearchResultView), bundle:nil)
        let searchResultViews = searchResultNib.instantiateWithOwner(nil, options: nil)
        self.searchResultView = searchResultViews[0] as! HMASearchResultView
        self.searchResultView.frame = rect
        self.searchResultView.hidden = true
        self.searchResultView.delegate = self
        self.view.addSubview(self.searchResultView)
        self.searchResultView.design()

        // search box
        let searchBoxNib = UINib(nibName: HMANSStringFromClass(HMASearchBoxView), bundle:nil)
        let searchBoxViews = searchBoxNib.instantiateWithOwner(nil, options: nil)
        self.searchBoxView = searchBoxViews[0] as! HMASearchBoxView
        self.searchBoxView.delegate = self
        self.view.addSubview(self.searchBoxView)
        self.searchBoxView.design(parentView: self.view)

        // duration view
        let durationViewNib = UINib(nibName: HMANSStringFromClass(HMADurationView), bundle:nil)
        let durationViews = durationViewNib.instantiateWithOwner(nil, options: nil)
        self.durationView = durationViews[0] as! HMADurationView
        self.durationView.delegate = self
        self.view.addSubview(self.durationView)
        self.durationView.design(parentView: self.view)

        // setting button
        let settingButtonNib = UINib(nibName: HMANSStringFromClass(HMASettingButton), bundle:nil)
        let settingButtonViews = settingButtonNib.instantiateWithOwner(nil, options: nil)
        self.settingButton = settingButtonViews[0] as! HMASettingButton
        self.settingButton.delegate = self
        self.settingButton.frame = CGRectMake(0, 0, self.settingButton.frame.size.width, self.settingButton.frame.size.height)
        self.view.addSubview(self.settingButton)

        // location manager
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 300
        self.locationManager.startUpdatingLocation()

        self.setUserInterfaceMode(HMAUserInterface.Mode.SetDestinations)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
/*
        if (segue.identifier == HMANSStringFromClass(HMAWebViewController)) {
            let nvc = segue.destinationViewController as! UINavigationController
            let vc = nvc.viewControllers[0] as! HMAWebViewController
            vc.initialURL = sender as? NSURL
        }
*/
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutUserInterfaces()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutUserInterfaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /// MARK: - event listener

    @IBAction func touchedUpInsideButton(button: UIButton) {
        if button == self.nextButton {
            // change UI mode
            if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
                self.setUserInterfaceMode(HMAUserInterface.Mode.SetRoute)
            }
            else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
                self.setUserInterfaceMode(HMAUserInterface.Mode.Cycle)
            }
            else if self.userInterfaceMode == HMAUserInterface.Mode.Cycle {
                self.mapView.removeAllDestinations()
                self.setUserInterfaceMode(HMAUserInterface.Mode.SetDestinations)
            }
        }
    }


    /// MARK: - notificatoin

    internal func changeUserInterfaceMode(notificatoin: NSNotification) {
        let mode = notificatoin.userInfo![HMANotificationCenter.ChangeUserInterfaceMode] as? Int
        if mode == HMAUserInterface.Mode.SetDestinations {
            self.mapView.removeAllDestinations()
        }
        else if mode == HMAUserInterface.Mode.SetRoute {
            self.mapView.removeAllWaypoints()
        }

        self.setUserInterfaceMode(mode!)
    }

    internal func GoToTheLocation(notificatoin: NSNotification) {
        let location = notificatoin.userInfo![HMANotificationCenter.GoToTheLocation] as? CLLocation
        self.mapView.animateWithCameraUpdate(GMSCameraUpdate.setTarget(location!.coordinate, zoom: self.mapView.camera.zoom))
    }


    /// MARK: - private api

    /**
     * set userInterfaceMode
     * @param mode HMAUserInterface.Mode
     **/
    private func setUserInterfaceMode(mode: Int) {
        self.userInterfaceMode = mode

        // update what map draws
        self.mapView.setUserInterfaceMode(mode)
        if mode == HMAUserInterface.Mode.SetRoute {
            self.mapView.updateWhatMapDraws()
        }
        else if mode == HMAUserInterface.Mode.Cycle {
            self.mapView.updateWhatMapDraws()
        }

        // draw
        self.mapView.draw()

        // routing
        if mode == HMAUserInterface.Mode.SetRoute {
            self.durationView.hide()
            self.mapView.requestRoute(
                { [unowned self] () in
                    self.mapView.updateCameraWhenRoutingHasDone()
                    self.durationView.show(destinationString: self.mapView.endAddress(), durationString: self.mapView.routeDuration())
                }
            )
        }

        // status bar color
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default

        // zoom
        if mode == HMAUserInterface.Mode.SetDestinations {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(self.mapView.projection.coordinateForPoint(self.mapView.center), zoom: HMAGoogleMap.Zoom.Default))
        }
        else if mode == HMAUserInterface.Mode.Cycle {
            let location = self.mapView.myLocation
            if location != nil {
                self.mapView.moveCamera(GMSCameraUpdate.setTarget(location!.coordinate, zoom: HMAGoogleMap.Zoom.Cycle))
            }
        }

        // next button
        self.updateNextButton()
        if mode == HMAUserInterface.Mode.SetDestinations { self.nextButton.setTitle("Route", forState: .Normal) }
        else if mode == HMAUserInterface.Mode.SetRoute { self.nextButton.setTitle("Start Cycling", forState: .Normal) }
        else if mode == HMAUserInterface.Mode.Cycle { self.nextButton.setTitle("End Cycling", forState: .Normal) }

        // circle button
        let isOn = (mode == HMAUserInterface.Mode.SetRoute) ? true : false
        self.crimeButton.setIsOn(isOn)
        self.comfortButton.setIsOn(isOn)
        self.wheelButton.setIsOn(isOn)

        // duration view
        if mode == HMAUserInterface.Mode.SetDestinations { self.durationView.hide() }

        // search box
        if mode == HMAUserInterface.Mode.SetDestinations { self.searchBoxView.show() }
        else { self.searchBoxView.hide() }

        // update slide menu
        let drawerController: HMADrawerController? = HMADrawerController.sharedInstance
        if drawerController != nil { (drawerController!.drawerViewController as! HMASlideMenuController).updateUserInterfaceMode(mode) }
    }

    /**
     * update next button
     **/
    private func updateNextButton() {
        let willShow = (self.mapView.destinations.count > 0)

        UIView.animateWithDuration(
            (willShow) ? 0.35 : 0.15,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: { [unowned self] in
                self.layoutUserInterfaces()
/*
                let offsetY = (willShow) ? self.nextButton.frame.size.height : 0

                let rect = UIScreen.mainScreen().bounds
                self.nextButton.frame = CGRectMake(
                    0,
                    rect.size.height-offsetY,
                    rect.size.width,
                    self.nextButton.frame.size.height
                )

                let circleButtons = [self.crimeButton, self.comfortButton, self.wheelButton]
                for var i = 0; i < circleButtons.count; i++ {
                    circleButtons[i].frame = CGRectMake(
                        circleButtons[i].frame.origin.x,
                        rect.size.height - (circleButtons[i].frame.size.height + 10.0) * CGFloat(i+2) - offsetY,
                        circleButtons[i].frame.size.width,
                        circleButtons[i].frame.size.height
                    )
                }

                self.mapView.padding = UIEdgeInsetsMake(0.0, 0.0, offsetY, 0.0)
*/
            },
            completion: { [unowned self] finished in
            }
        )
    }

    /**
     * fix UserInterface positions
     **/
    private func layoutUserInterfaces() {
        let rect = UIScreen.mainScreen().bounds
        self.settingButton.frame = CGRectMake(0, 0, self.settingButton.frame.size.width, self.settingButton.frame.size.height)
        self.mapView.frame = rect
        self.searchResultView.frame = rect

        let offsetY = (self.mapView.destinations.count > 0) ? self.nextButton.frame.size.height : 0
        self.nextButton.frame = CGRectMake(
            0,
            rect.size.height-offsetY,
            rect.size.width,
            self.nextButton.frame.size.height
        )
        let circleButtons = [self.crimeButton, self.comfortButton, self.wheelButton]
        for var i = 0; i < circleButtons.count; i++ {
            circleButtons[i].frame = CGRectMake(
                circleButtons[i].frame.origin.x,
                rect.size.height - (circleButtons[i].frame.size.height + 10.0) * CGFloat(i+2) - offsetY,
                circleButtons[i].frame.size.width,
                circleButtons[i].frame.size.height
            )
        }
        self.mapView.padding = UIEdgeInsetsMake(0.0, 0.0, offsetY, 0.0)
    }

}


/// MARK: - UIActionSheetDelegate
extension HMAViewController: UIActionSheetDelegate {

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {

        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            // delete destination
            if buttonIndex == 0 {
                self.mapView.deleteEditingMarker()
                self.mapView.updateWhatMapDraws()
                self.mapView.draw()
                self.updateNextButton()
            }
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            // delete waypoint
            if buttonIndex == 0 {
                self.mapView.deleteEditingMarker()
                self.mapView.updateWhatMapDraws()
                self.mapView.draw()
                self.durationView.hide()
                self.mapView.requestRoute({ [unowned self] () in
                    self.durationView.show(destinationString: self.mapView.endAddress(), durationString: self.mapView.routeDuration())
                })
            }
        }
    }
}


/// MARK: - CLLocationManagerDelegate
extension HMAViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        let location = self.mapView.myLocation
        if location == nil { return }

        let zoom = (self.userInterfaceMode == HMAUserInterface.Mode.Cycle) ? HMAGoogleMap.Zoom.Cycle : HMAGoogleMap.Zoom.Default
        self.mapView.camera = GMSCameraPosition.cameraWithLatitude(
            location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: zoom
        )
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    }

}


/// MARK: - GMSMapViewDelegate
extension HMAViewController: GMSMapViewDelegate {

    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            self.mapView.appendDestination(coordinate)
            self.updateNextButton()
            self.mapView.updateWhatMapDraws()
            self.mapView.draw()
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            self.mapView.appendWaypoint(coordinate)
            self.mapView.updateWhatMapDraws()
            self.mapView.draw()
            self.durationView.hide()
            self.mapView.requestRoute({ [unowned self] () in
                self.durationView.show(destinationString: self.mapView.endAddress(), durationString: self.mapView.routeDuration())
            })
        }
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            // ask to delete destination marker
            if marker.isKindOfClass(HMADestinationMarker) {
                self.mapView.startEditingMarker(marker)
                self.showDeleteMarkerActionSheet()
                return false
            }
            else {
                self.mapView.selectedMarker = marker
                return true
            }
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            // ask to delete waypoint marker
            if marker.isKindOfClass(HMAWaypointMarker) {
                self.mapView.startEditingMarker(marker)
                self.showDeleteMarkerActionSheet()
                return false
            }
            else {
                self.mapView.selectedMarker = marker
                return true
            }
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.Cycle {
            self.mapView.selectedMarker = marker
            return true
        }

        self.mapView.selectedMarker = marker
        return true
    }

    func mapView(mapView: GMSMapView,  didBeginDraggingMarker marker: GMSMarker) {
        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            self.mapView.startEditingMarker(marker)
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            self.mapView.startEditingMarker(marker)
        }
    }

    func mapView(mapView: GMSMapView,  didEndDraggingMarker marker: GMSMarker) {
        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            self.mapView.endDraggingMarker(marker)
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            self.mapView.endDraggingMarker(marker)
            self.durationView.hide()
            self.mapView.requestRoute({ [unowned self] () in
                self.durationView.show(destinationString: self.mapView.endAddress(), durationString: self.mapView.routeDuration())
            })
        }
    }

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        if !(self.mapView.isEditingMarkerNow()) {
            self.mapView.updateWhatMapDraws()
            self.mapView.draw()
        }
    }

    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
    }

    func mapView(mapView: GMSMapView,  didDragMarker marker:GMSMarker) {
    }

    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
    }

    func showDeleteMarkerActionSheet() {
        let actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.addButtonWithTitle("Delete")
        actionSheet.destructiveButtonIndex = 0
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = 1
        actionSheet.showInView(self.view)
    }
}


/// MARK: - KYDrawerControllerDelegate
extension HMAViewController: KYDrawerControllerDelegate {

    func drawerController(drawerController: KYDrawerController, stateChanged state: KYDrawerController.DrawerState) {
    }

}


/// MARK: - HMASettingButtonDelegate
extension HMAViewController: HMASettingButtonDelegate {

    func settingButton(settingButton: HMASettingButton) {
        HMADrawerController.sharedInstance.setDrawerState(.Opened, animated: true)
    }

}


/// MARK: - HMACircleButtonDelegate
extension HMAViewController: HMACircleButtonDelegate {

    func circleButton(circleButton: HMACircleButton, wasOn: Bool) {
        if circleButton == self.crimeButton {
            self.mapView.shouldDrawCrimes = wasOn
            if wasOn { HMACrimeData.requestToGetCrimeData() }
        }
        else if circleButton == self.comfortButton {
            self.mapView.shouldDrawComfort = wasOn
            if wasOn {
                HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Humidity)
                HMASensorData.requestToGetSensorData(sensorType: HMASensor.SensorType.Temperature)
            }
        }
        else if circleButton == self.wheelButton {
            self.mapView.shouldDrawWheel = wasOn
            if wasOn {
                HMAWheelData.requestToGetWheelData(dataType: HMAWheel.DataType.RiderTorque, max: nil, min: HMAWheel.Min.RiderTorque)
                HMAWheelData.requestToGetWheelData(dataType: HMAWheel.DataType.Acceleration, max: HMAWheel.Max.Acceleration, min: nil)
            }
        }
        self.mapView.updateWhatMapDraws()
        self.mapView.draw()
    }

}


/// MARK: - HMADurationViewDelegate
extension HMAViewController: HMADurationViewDelegate {

    func touchedUpInside(#durationView: HMADurationView) {
    }

    func willShow(#durationView: HMADurationView) {
    }

    func willHide(#durationView: HMADurationView) {
    }

}


/// MARK: - HMASearchBoxViewDelegate
extension HMAViewController: HMASearchBoxViewDelegate {

    func searchBoxWasActive(#searchBoxView: HMASearchBoxView) {
        self.searchResultView.hidden = false
        self.settingButton.hidden = true
    }

    func searchBoxWasInactive(#searchBoxView: HMASearchBoxView) {
        self.searchResultView.hidden = true
        self.settingButton.hidden = false
    }

    func searchDidFinish(#searchBoxView: HMASearchBoxView, destinations: [HMADestination]) {
        self.searchResultView.updateDestinations(destinations)
    }

    func clearButtonTouchedUpInside(#searchBoxView: HMASearchBoxView) {
        if self.searchBoxView.isActive { return }
        self.mapView.draw()
    }

    func geoLocationSearchDidFinish(#searchBoxView: HMASearchBoxView, coordinate: CLLocationCoordinate2D) {
        self.mapView.appendDestination(coordinate)
        self.mapView.updateWhatMapDraws()
        self.mapView.draw()
        self.updateNextButton()
    }

}


/// MARK: - HMASearchResultViewDelegate
extension HMAViewController: HMASearchResultViewDelegate {

    func didSelectRow(#searchResultView: HMASearchResultView, selectedDestination: HMADestination) {
        self.searchBoxView.endSearch()
        self.searchBoxView.setSearchText(selectedDestination.desc)

        let location = self.mapView.myLocation
        if location == nil { return }
        self.searchBoxView.startSearchGeoLocation(coordinate: location!.coordinate)
    }

}
