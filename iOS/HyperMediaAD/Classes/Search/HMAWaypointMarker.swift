/// MARK: - HMAWaypointMarker
class HMAWaypointMarker: GMSMarker {

    /// MARK: - public api

    /**
     * do settings (design, draggable, etc)
     **/
    func doSettings() {
        self.icon = HMAWaypointMarker.markerImageWithColor(UIColor.blueColor())
        self.draggable = true
    }

}
