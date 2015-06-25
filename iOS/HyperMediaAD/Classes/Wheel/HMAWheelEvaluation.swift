/// Minus Acceleration
struct HMAMinusAcceleration {
    static let Level1: Double         = -2.0
    static let Level2: Double         = -2.5
    static let Level3: Double         = -3.0
    static let Level4: Double         = -3.5
    static let Level5: Double         = -4.0
    static let Level6: Double         = -4.5
    static let Level7: Double         = -5.0

    static let Min: Double            = HMAMinusAcceleration.Level7
    static let Max: Double            = HMAMinusAcceleration.Level1

    static let MinAlpha: CGFloat      = 0.25
    static let MaxAlpha: CGFloat      = 1.00
}

/// RiderTorque
struct HMARiderTorque {
    static let Level1: Double         = 12.0
    static let Level2: Double         = 14.0
    static let Level3: Double         = 16.0
    static let Level4: Double         = 18.0
    static let Level5: Double         = 20.0
    static let Level6: Double         = 22.0
    static let Level7: Double         = 30.0

    static let Min: Double            = HMAMinusAcceleration.Level1
    static let Max: Double            = HMAMinusAcceleration.Level7

    static let MinAlpha: CGFloat      = 0.25
    static let MaxAlpha: CGFloat      = 1.00
}


/// MARK: - HMAWheelEvaluation
class HMAWheelEvaluation: NSObject {

    /// MARK: - property

    /// evaluation function from Acceleration
    var accelSplineCurve: SAMCubicSpline!
    /// evaluation function from RiderTorque
    var torqueSplineCurve: SAMCubicSpline!


    /// MARK: - initialization

    /**
     * Initialization
     * @return HMAWheelEvaluation
     */
    override init() {
        super.init()

        self.accelSplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMAMinusAcceleration.Level7), HMAMinusAcceleration.MaxAlpha)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAMinusAcceleration.Level6), 0.80)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAMinusAcceleration.Level5), 0.65)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAMinusAcceleration.Level4), 0.50)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAMinusAcceleration.Level3), 0.35)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAMinusAcceleration.Level2), 0.30)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAMinusAcceleration.Level1), HMAMinusAcceleration.MinAlpha)),
        ])
        self.torqueSplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMARiderTorque.Level1), HMARiderTorque.MinAlpha)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMARiderTorque.Level2), 0.30)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMARiderTorque.Level3), 0.35)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMARiderTorque.Level4), 0.50)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMARiderTorque.Level5), 0.65)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMARiderTorque.Level6), 0.80)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMARiderTorque.Level7), HMARiderTorque.MaxAlpha)),
        ])
    }


    /// MARK: - public api

    /**
     * return color for minus acceleration visualization
     * @param accelA Double
     * @param accelB Double
     * @return accel evaluation (how much minus acceleration)
     */
    func getMinusAccelerationColor(#accelA: Double, accelB: Double) -> UIColor {
        let average = (accelA + accelB) / 2.0
        if average < HMAMinusAcceleration.Min { return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: HMAMinusAcceleration.MaxAlpha) }
        if average > HMAMinusAcceleration.Max { return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: HMAMinusAcceleration.MinAlpha) }

        var alpha = self.accelSplineCurve.interpolate(CGFloat(average))
        if alpha < HMAMinusAcceleration.MinAlpha { return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: HMAMinusAcceleration.MinAlpha) }
        if alpha > HMAMinusAcceleration.MaxAlpha { return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: HMAMinusAcceleration.MaxAlpha) }
        return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: CGFloat(alpha))
    }

    /**
     * return color for rider torque
     * @param torqueA Double
     * @param torqueB Double
     * @return torque evaluation (how much torque)
     */
    func getRiderTorqueColor(#torqueA: Double, torqueB: Double) -> UIColor {
        let average = (torqueA + torqueB) / 2.0
        if average < HMARiderTorque.Min { return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: HMARiderTorque.MaxAlpha) }
        if average > HMARiderTorque.Max { return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: HMARiderTorque.MinAlpha) }

        var alpha = self.torqueSplineCurve.interpolate(CGFloat(average))
        if alpha < HMARiderTorque.MinAlpha { return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: HMARiderTorque.MinAlpha) }
        if alpha > HMARiderTorque.MaxAlpha { return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: HMARiderTorque.MaxAlpha) }
        return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: CGFloat(alpha))
    }

    /**
     * get minus acceleration graph view
     * @return minus acceleration graph view
     **/
    func minusAccelerationGraphView() -> FSLineChart {
        var chartData: [CGFloat] = []
        let min = CGFloat(HMAMinusAcceleration.Min)
        let max = CGFloat(HMAMinusAcceleration.Max)
        for var x = min; x <= max; x += 0.05 {
            var y = self.accelSplineCurve.interpolate(x)
            if y < HMAMinusAcceleration.MinAlpha { y = HMAMinusAcceleration.MinAlpha }
            else if y > HMAMinusAcceleration.MaxAlpha { y = HMAMinusAcceleration.MaxAlpha }
            chartData.append(y)
        }
        let lineChart = FSLineChart(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width * 0.6))
        lineChart.verticalGridStep = 5
        lineChart.horizontalGridStep = 9
        lineChart.labelForIndex = { (item) in
            return "\(item)"
        }
        lineChart.labelForValue = { (value) in
            return "\(value)"
        }
        lineChart.setChartData(chartData)
        return lineChart
    }

    /**
     * get rider torque graph view
     * @return rider torque graph view
     **/
    func riderTorqueGraphView() -> FSLineChart {
        var chartData: [CGFloat] = []
        let min = CGFloat(HMARiderTorque.Min)
        let max = CGFloat(HMARiderTorque.Max)
        for var x = min; x <= max; x += 0.05 {
            var y = self.torqueSplineCurve.interpolate(x)
            if y < HMARiderTorque.MinAlpha { y = HMARiderTorque.MinAlpha }
            else if y > HMARiderTorque.MaxAlpha { y = HMARiderTorque.MaxAlpha }
            chartData.append(y)
        }
        let lineChart = FSLineChart(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width * 0.6))
        lineChart.verticalGridStep = 5
        lineChart.horizontalGridStep = 9
        lineChart.labelForIndex = { (item) in
            return "\(item)"
        }
        lineChart.labelForValue = { (value) in
            return "\(value)"
        }
        lineChart.setChartData(chartData)
        return lineChart
    }

}
