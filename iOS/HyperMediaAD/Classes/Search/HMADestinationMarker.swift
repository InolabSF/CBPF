/// MARK: - HMADestinationMarker
class HMADestinationMarker: GMSMarker {

    /// MARK: - public api

    /**
     * do settings (design, draggable, etc)
     **/
    func doSettings() {
        self.draggable = true
        self.tappable = true
    }

}
