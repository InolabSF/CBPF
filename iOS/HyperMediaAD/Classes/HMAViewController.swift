import UIKit
import CoreLocation


/// MARK: - HMAViewController
class HMAViewController: UIViewController, CLLocationManagerDelegate {

    /// MARK: - property
    var destinationString: String = ""

    var mapView: HMAMapView!
    var searchBoxView: HMASearchBoxView!
    var searchResultView: HMASearchResultView!
    var horizontalTableView: HMAHorizontalTableView!
    var locationManager: CLLocationManager!


    /// MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.doSettings()
/*
        // display comfort evaluation graph
        let comfort = HMAComfort()
        let graphs = [ comfort.heatIndexGraphView(), comfort.pm25GraphView(), comfort.soundLevelGraphView(), ]
        var offsetY: CGFloat = 20.0
        for var i = 0; i < graphs.count; i++ {
            let graph = graphs[i]
            graph.frame = CGRectMake(0, offsetY, graph.frame.size.width, graph.frame.size.height)
            self.view.addSubview(graph)
            offsetY += graph.frame.size.height
        }
*/
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
        self.mapView.myLocationEnabled = true
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)

        // search result
        let searchResultNib = UINib(nibName: HMANSStringFromClass(HMASearchResultView), bundle:nil)
        let searchResultViews = searchResultNib.instantiateWithOwner(nil, options: nil)
        self.searchResultView = searchResultViews[0] as! HMASearchResultView
        self.searchResultView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
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

        // horizontal table view
        let horizontalTableViewNib = UINib(nibName: HMANSStringFromClass(HMAHorizontalTableView), bundle:nil)
        let horizontalTableViews = horizontalTableViewNib.instantiateWithOwner(nil, options: nil)
        self.horizontalTableView = horizontalTableViews[0] as! HMAHorizontalTableView
        self.horizontalTableView.frame = CGRectMake(0, self.view.frame.size.height-self.horizontalTableView.frame.size.height, self.view.frame.size.width, self.horizontalTableView.frame.size.height)
        self.view.addSubview(self.horizontalTableView)
        self.horizontalTableView.doSettings()
        self.horizontalTableView.delegate = self

        // location manager
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 300
        self.locationManager.startUpdatingLocation()

        self.view.bringSubviewToFront(self.horizontalTableView)
        self.view.bringSubviewToFront(self.searchResultView)
        self.view.bringSubviewToFront(self.searchBoxView)
    }

    /**
     * request dirction API and render direction
     */
    private func requestDirectoin() {
        if self.destinationString == "" { return }

        HMAGoogleMapClient.sharedInstance.cancelGetRoute()

        // google map direction API
        let location = self.mapView.myLocation
        if location == nil { return }
        let coordinate = location.coordinate
        HMAGoogleMapClient.sharedInstance.getRoute(
            queries: [ "origin" : "\(coordinate.latitude),\(coordinate.longitude)", "destination" : self.destinationString, ],
            completionHandler: { [unowned self] (json) in
                self.mapView.setRouteJSON(json)
                self.mapView.draw()
            }
        )
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
        self.mapView.appendWaypoint(coordinate)
        self.requestDirectoin()
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        self.mapView.selectedMarker = marker
        return true
    }

    func mapView(mapView: GMSMapView,  didBeginDraggingMarker marker: GMSMarker) {
        self.mapView.startMovingWaypoint(marker.position)
    }

    func mapView(mapView: GMSMapView,  didEndDraggingMarker marker: GMSMarker) {
        self.mapView.endMovingWaypoint(marker.position)
        self.requestDirectoin()
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
        // yelp
        if marker.isKindOfClass(HMAYelpMaker) {
            let m = marker as! HMAYelpMaker
            if m.yelpData.mobile_url != nil {
                self.performSegueWithIdentifier(HMANSStringFromClass(HMAWebViewController), sender: m.yelpData.mobile_url)
            }
        }
    }

}


/// MARK: - HMASearchBoxViewDelegate
extension HMAViewController: HMASearchBoxViewDelegate {

    func searchBoxWasActive(#searchBoxView: HMASearchBoxView) {
        self.searchResultView.hidden = false
    }

    func searchBoxWasInactive(#searchBoxView: HMASearchBoxView) {
        self.searchResultView.hidden = true
        self.searchBoxView.setSearchText(self.destinationString)
    }

    func searchDidFinish(#searchBoxView: HMASearchBoxView, destinations: [HMADestination]) {
        self.searchResultView.updateDestinations(destinations)
    }

    func clearButtonTouchedUpInside(#searchBoxView: HMASearchBoxView) {
        if self.searchBoxView.isActive { return }
        self.mapView.setRouteJSON(nil)
        self.destinationString = ""
        self.mapView.draw()
    }

}


/// MARK: - HMASearchResultViewDelegate
extension HMAViewController: HMASearchResultViewDelegate {

    func didSelectRow(#searchResultView: HMASearchResultView, selectedDestination: HMADestination) {
        self.searchBoxView.endSearch()
        self.searchBoxView.setSearchText(selectedDestination.desc)
        if self.destinationString == selectedDestination.desc { return }
        self.destinationString = selectedDestination.desc
        self.mapView.removeAllWaypoints()
        self.requestDirectoin()
    }

}


/// MARK: - HMAHorizontalTableViewDelegate
extension HMAViewController: HMAHorizontalTableViewDelegate {

    func tableView(tableView: HMAHorizontalTableView, indexPath: NSIndexPath, wasOn: Bool) {
        let visualizationType = tableView.dataSource[indexPath.row].visualizationType
        self.mapView.setVisualizationType(wasOn ? visualizationType : HMAGoogleMap.Visualization.None)
        self.mapView.updateWhatMapDraws()
        self.mapView.draw()

        // yelp
        if wasOn {
            var term = ""
            switch visualizationType {
                case HMAGoogleMap.Visualization.Yelp:
                    break
                case HMAGoogleMap.Visualization.YelpCafe:
                    term = "cafe"
                    break
                case HMAGoogleMap.Visualization.YelpRestaurant:
                    term = "restaurant"
                    break
                case HMAGoogleMap.Visualization.YelpBicycle:
                    term = "bicycle"
                    break
                default:
                    return
            }
            HMAYelpClient.sharedInstance.getSearchResult(
                term: term,
                completionHandler: { [unowned self] (json) in
                    self.mapView.draw()
                }
            )
        }
    }

}
