/// MARK: - HMASensorMarker
class HMASensorMarker: GMSMarker {

    /// MARK: - public api

    /**
     * do settings (design, draggable, etc)
     * @param sensorData HMASensorData
     **/
    func doSettings(#sensorData: HMASensorData) {
        let sensorType = sensorData.sensor_id.integerValue
        var iconName = ""
        switch (sensorType) {
            case HMASensor.SensorType.Noise:
                iconName = "noise"
                break
            case HMASensor.SensorType.Pm25:
                iconName = "pm25"
                break
            default:
                break
        }

        var image = UIImage(named: "marker_sensor_"+iconName)
        if image == nil { image = UIImage(named: "marker_question") }
        self.icon = image
        self.draggable = false
    }

}
