import UIKit
import CoreLocation


/// MARK: - HMAViewController
class HMAViewController: UIViewController, CLLocationManagerDelegate {

    /// MARK: - property
    var locationManager: CLLocationManager!
    var userInterfaceMode = HMAUserInterface.Mode.SetDestinations
    var mapView: HMAMapView!
    //var yelpButton: HMABottomButton!


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.doSettings()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == HMANSStringFromClass(HMAWebViewController)) {
            let nvc = segue.destinationViewController as! UINavigationController
            let vc = nvc.viewControllers[0] as! HMAWebViewController
            vc.initialURL = sender as? NSURL
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /// MARK: - event listener


    /// MARK: - private api

    /**
     * do settings
     **/
    private func doSettings() {
        // google map view
        self.mapView = HMAMapView.sharedInstance
        self.mapView.frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        self.mapView.delegate = self
        self.mapView.hmaDelegate = self
        self.view.addSubview(self.mapView)
        self.mapView.doSettings()
        self.mapView.setUserInterfaceMode(self.userInterfaceMode)
/*
        // yelp
        let yelpButtonNib = UINib(nibName: HMANSStringFromClass(HMABottomButton), bundle:nil)
        let yelpButtonViews = yelpButtonNib.instantiateWithOwner(nil, options: nil)
        self.yelpButton = yelpButtonViews[0] as! HMABottomButton
        self.yelpButton.frame = CGRectMake(
            0, self.view.frame.size.height - self.yelpButton.frame.size.height,
            self.view.frame.size.width, self.yelpButton.frame.size.height
        )
        self.view.addSubview(self.yelpButton)
        self.yelpButton.design()
        self.yelpButton.delegate = self
*/
        // location manager
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 300
        self.locationManager.startUpdatingLocation()
    }

}


/// MARK: - UIActionSheetDelegate
extension HMAViewController: UIActionSheetDelegate {

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {

        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            // delete destination
            if buttonIndex == 0 {
                self.mapView.deleteEditingDestination()
                self.mapView.updateWhatMapDraws()
                self.mapView.draw()
                self.mapView.setUserInterfaceMode(self.userInterfaceMode)
            }
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            // delete waypoint
            if buttonIndex == 0 {
                self.mapView.deleteEditingWaypoint()
                self.mapView.updateWhatMapDraws()
                self.mapView.draw()
                self.mapView.requestRoute()
            }
        }
    }
}


/// MARK: - CLLocationManagerDelegate
extension HMAViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        let location = self.mapView.myLocation
        if location == nil { return }
        self.mapView.camera = GMSCameraPosition.cameraWithLatitude(
            location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: HMAGoogleMap.Zoom
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
            self.mapView.setUserInterfaceMode(self.userInterfaceMode)
            self.mapView.updateWhatMapDraws()
            self.mapView.draw()
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            self.mapView.appendWaypoint(coordinate)
            self.mapView.updateWhatMapDraws()
            self.mapView.draw()
            self.mapView.requestRoute()
        }
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            // ask to delete destination marker
            if marker.isKindOfClass(HMADestinationMarker) {
                self.mapView.startEditingDestination(marker.position)
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
                self.mapView.startEditingWaypoint(marker.position)
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
            self.mapView.startDraggingDestination(marker.position)
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            self.mapView.startDraggingWaypoint(marker.position)
        }
    }

    func mapView(mapView: GMSMapView,  didEndDraggingMarker marker: GMSMarker) {
        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            self.mapView.endDraggingDestination(marker.position)
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            self.mapView.endDraggingWaypoint(marker.position)
            self.mapView.requestRoute()
        }
    }

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        if !(self.mapView.isDraggingNow()) {
            self.mapView.updateWhatMapDraws()
            self.mapView.draw()
        }
    }

    func mapView(mapView: GMSMapView,  didDragMarker marker:GMSMarker) {
    }

    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
/*
        // yelp
        if marker.isKindOfClass(HMAYelpMaker) {
            let m = marker as! HMAYelpMaker
            if m.yelpData.mobile_url != nil {
                self.performSegueWithIdentifier(HMANSStringFromClass(HMAWebViewController), sender: m.yelpData.mobile_url)
            }
        }
*/
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


/// MARK: - HMAMapViewDelegate
extension HMAViewController: HMAMapViewDelegate {

    func touchedUpInsideNextButton(#mapView: HMAMapView) {
        if self.userInterfaceMode == HMAUserInterface.Mode.SetDestinations {
            self.userInterfaceMode = HMAUserInterface.Mode.SetRoute
            self.mapView.setUserInterfaceMode(self.userInterfaceMode)
            self.mapView.updateWhatMapDraws()
            self.mapView.draw()
            self.mapView.requestRoute()
        }
        else if self.userInterfaceMode == HMAUserInterface.Mode.SetRoute {
            self.userInterfaceMode = HMAUserInterface.Mode.Cycle
            self.mapView.setUserInterfaceMode(self.userInterfaceMode)
            self.mapView.updateWhatMapDraws()
            self.mapView.draw()
        }
    }

}

/*
/// MARK: - HMABottomButtonDelegate
extension HMAViewController: HMABottomButtonDelegate {

    func bottomButtonWasClicked(#bottomButton: HMABottomButton) {
        let modalViewNib = UINib(nibName: HMANSStringFromClass(HMAYelpSemiModalView), bundle:nil)
        let modalViews = modalViewNib.instantiateWithOwner(nil, options: nil)
        var modalView = modalViews[0] as! HMAYelpSemiModalView
        self.presentModalView(modalView)
        modalView.delegate = self
    }

}


/// MARK: - HMAYelpSemiModalViewDelegate
extension HMAViewController: HMAYelpSemiModalViewDelegate {

    func semiModalView(semiModalView: HMAYelpSemiModalView, didDecideSearchWord searchWord: String) {
        HMAYelpClient.sharedInstance.getSearchResult(
            term: searchWord,
            completionHandler: { [unowned self] (json) in
                self.mapView.draw()
            }
        )
    }

}
*/

/*
        // display sensor evaluation graph
        let sensorEvaluation = HMASensorEvaluation()
        let sensorGraphs = [ sensorEvaluation.heatIndexGraphView(), sensorEvaluation.pm25GraphView(), sensorEvaluation.soundLevelGraphView(), ]
        var sensorOffsetY: CGFloat = 20.0
        for var i = 0; i < sensorGraphs.count; i++ {
            let graph = sensorGraphs[i]
            graph.frame = CGRectMake(0, sensorOffsetY, graph.frame.size.width, graph.frame.size.height)
            self.view.addSubview(graph)
            sensorOffsetY += graph.frame.size.height
        }
*/
/*
        // display wheel evaluation graph
        let wheelEvaluation = HMAWheelEvaluation()
        let wheelGraphs = [ wheelEvaluation.minusAccelerationGraphView(), ]
        var wheelOffsetY: CGFloat = 20.0
        for var i = 0; i < wheelGraphs.count; i++ {
            let graph = wheelGraphs[i]
            graph.frame = CGRectMake(0, wheelOffsetY, graph.frame.size.width, graph.frame.size.height)
            self.view.addSubview(graph)
            wheelOffsetY += graph.frame.size.height
        }
*/
