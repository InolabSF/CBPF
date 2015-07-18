/// MARK: - HMAMapOverlayManager
class HMAMapOverlayManager {

    /// MARK: - property

    /// overlays
    private var overlays: [GMSOverlay] = []


    /// MARK: - initialization

    init() {
    }


    /// MARK: - public api

    /**
     * append new overlay
     * @param overlay GMSOverlay
     **/
    func appendOverlay(overlay: GMSOverlay) {
        self.overlays.append(overlay)
    }

    /**
     * clear overlays
     **/
    func clearOverlays() {
        for overlay in self.overlays { overlay.map = nil }
        self.overlays = []
    }

}
