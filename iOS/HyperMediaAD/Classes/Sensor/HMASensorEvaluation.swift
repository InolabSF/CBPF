/// MARK: - constant

/// Heat Index
struct HMAHeatIndex {
    static let Cold: Double         = 55.0
    static let Chille: Double       = 57.5
    static let NotChille: Double    = 62.5
    static let Comfort: Double      = 67.5
    static let NotWarm: Double      = 72.5
    static let Warm: Double         = 77.5
    static let Hot: Double          = 82.5
    static let Boiling: Double      = 85.0

    static let Min: Double          = HMAHeatIndex.Cold
    static let Max: Double          = HMAHeatIndex.Boiling
}

/// PM2.5
struct HMAPM25 {
    static let Level1: Double       = 0.0
    static let Level2: Double       = 12.0
    static let Level3: Double       = 23.5
    static let Level4: Double       = 35.0
    static let Level5: Double       = 45.0
    static let Level6: Double       = 55.0

    static let Min: Double          = HMAPM25.Level1
    static let Max: Double          = HMAPM25.Level6
}

/// Sound Level
struct HMASound {
    static let Level1: Double   = 10.0      // Breathing
    static let Level2: Double   = 20.0      // Whisper, rustling leaves
    static let Level3: Double   = 30.0      // Quiet rural area
    static let Level4: Double   = 40.0      // Library, bird calls (44 dB); lowest limit of urban ambient sound
    static let Level5: Double   = 50.0      // Quiet suburb, conversation at home. Large electrical transformers at 100 ft
    static let Level6: Double   = 60.0      // Conversation in restaurant, office, background music, Air conditioning unit at 100 ft
    static let Level7: Double   = 70.0      // Passenger car at 65 mph at 25 ft (77 dB); freeway at 50 ft from pavement edge 10 a.m. (76 dB). Living room music (76 dB); radio or TV-audio, vacuum cleaner (70 dB).
    static let Level8: Double   = 80.0      // Garbage disposal, dishwasher, average factory, freight train (at 15 meters). Car wash at 20 ft (89 dB); propeller plane flyover at 1000 ft (88 dB); diesel truck 40 mph at 50 ft (84 dB); diesel train at 45 mph at 100 ft (83 dB). Food blender (88 dB); milling machine (85 dB); garbage disposal (80 dB).
    static let Level9: Double   = 90.0      // Boeing 737 or DC-9 aircraft at one nautical mile (6080 ft) before landing (97 dB); power mower (96 dB); motorcycle at 25 ft (90 dB). Newspaper press (97 dB).
    static let Level10: Double  = 100.0     // Jet take-off (at 305 meters), use of outboard motor, power lawn mower, motorcycle, farm tractor, jackhammer, garbage truck. Boeing 707 or DC-8 aircraft at one nautical mile (6080 ft) before landing (106 dB); jet flyover at 1000 feet (103 dB); Bell J-2A helicopter at 100 ft (100 dB).
    static let Level11: Double  = 110.0     // Steel mill, auto horn at 1 meter. Turbo-fan aircraft at takeoff power at 200 ft (118 dB). Riveting machine (110 dB); live rock music (108 - 114 dB).
    static let Level12: Double  = 120.0     // Thunderclap, chain saw. Oxygen torch (121 dB).
    static let Level13: Double  = 130.0     // Military jet aircraft take-off from aircraft carrier with afterburner at 50 ft (130 dB).
    static let Level14: Double  = 140.0     // Aircraft carrier deck
    static let Level15: Double  = 150.0     // Jet take-off (at 25 meters)

    static let Min: Double          = HMASound.Level1
    static let Max: Double          = HMASound.Level9
}


/// MARK: - HMASensorEvaluation
class HMASensorEvaluation: NSObject {

    /// MARK: - property

    /// evaluation function from heat index
    var heatIndexSplineCurve: SAMCubicSpline!
    /// evaluation function from PM2.5
    var pm25SplineCurve: SAMCubicSpline!
    /// evaluation function from sound level
    var soundLevelSplineCurve: SAMCubicSpline!


    /// MARK: - initialization

    /**
     * Initialization
     * @return HMASensorEvaluation
     */
    override init() {
        super.init()
        self.heatIndexSplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMAHeatIndex.Cold), 1.00)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAHeatIndex.Chille), 0.35)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAHeatIndex.NotChille), 0.05)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAHeatIndex.Comfort), 0.00)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAHeatIndex.NotWarm), 0.05)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAHeatIndex.Warm), 0.20)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAHeatIndex.Hot), 0.50)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAHeatIndex.Boiling), 1.00)),
        ])
        self.pm25SplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMAPM25.Level1), 0.00)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAPM25.Level2), 0.05)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAPM25.Level3), 0.20)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAPM25.Level4), 0.50)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAPM25.Level5), 0.90)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMAPM25.Level6), 1.00)),
        ])
        self.soundLevelSplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level1), 0.00)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level2), 0.01)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level3), 0.03)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level4), 0.05)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level5), 0.10)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level6), 0.20)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level7), 0.35)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level8), 0.60)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMASound.Level9), 1.00)),
        ])
    }


    /// MARK: - public api

    /**
     * get heat index evaluation if it's comfortable, the value goes 0. if it isn't comfortable, the value goes 1.
     * @param humidity Double
     * @param temperature Double
     * @return comfort evaluation
     */
    func getHeatIndexWeight(#humidity: Double, temperature: Double) -> Double {
        let celsius = (temperature - 32.0) / 1.8
        let heatIndex = 0.81 * celsius + 0.01 * humidity * (0.99 * celsius - 14.3) + 46.3
        if heatIndex < HMAHeatIndex.Min { return 0.0 }
        if heatIndex > HMAHeatIndex.Max { return 1.0 }
        var weight = Double(self.heatIndexSplineCurve.interpolate(CGFloat(heatIndex)))
        if weight < 0.0 { return 0.0 }
        if weight > 1.0 { return 1.0 }
        return weight
    }

    /**
     * get evaluation if it's comfortable, the value goes 0. if it isn't comfortable, the value goes 1.
     * @param parameter comfort parameter
     * @return comfort evaluation
     */
    func getPM25Weight(#parameter: Double) -> Double{
        let pm25 = parameter
        if pm25 < HMAPM25.Min { return 0.0 }
        if pm25 > HMAPM25.Max { return 1.0 }
        var weight = Double(self.pm25SplineCurve.interpolate(CGFloat(pm25)))
        if weight < 0.0 { return 0.0 }
        if weight > 1.0 { return 1.0 }
        return weight
    }

    /**
     * get sound level evaluation if it's comfortable, the value goes 0. if it isn't comfortable, the value goes 1.
     * @param parameter comfort parameter
     * @return sound level evaluation
     */
    func getSoundLevelWeight(#parameter: Double) -> Double{
        let soundLevel = parameter
        if soundLevel < HMASound.Min { return 0.0 }
        if soundLevel > HMASound.Max { return 1.0 }
        var weight = Double(self.soundLevelSplineCurve.interpolate(CGFloat(soundLevel)))
        if weight < 0.0 { return 0.0 }
        if weight > 1.0 { return 1.0 }
        return weight
    }

    /**
     * get heat index graph view
     * @return heat index graph view
     **/
    func heatIndexGraphView() -> FSLineChart {
        var chartData: [CGFloat] = []
        let min = CGFloat(HMAHeatIndex.Min)
        let max = CGFloat(HMAHeatIndex.Max)
        for var x = min; x <= max; x += 1.0 {
            var y = self.heatIndexSplineCurve.interpolate(x)
            if y < 0 { y = 0 }
            else if y > 1.0 { y = 1.0 }
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
     * get PM2.5 graph view
     * @return PM2.5 graph view
     **/
    func pm25GraphView() -> FSLineChart {
        var chartData: [CGFloat] = []
        let min = CGFloat(HMAPM25.Min)
        let max = CGFloat(HMAPM25.Max)
        for var x = min; x <= max; x += 1.0 {
            var y = self.pm25SplineCurve.interpolate(x)
            if y < 0 { y = 0 }
            else if y > 1.0 { y = 1.0 }
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
     * get sound level graph view
     * @return sound level graph view
     **/
    func soundLevelGraphView() -> FSLineChart {
        var chartData: [CGFloat] = []
        let min = CGFloat(HMASound.Min)
        let max = CGFloat(HMASound.Max)
        for var x = min; x <= max; x += 1.0 {
            var y = self.soundLevelSplineCurve.interpolate(x)
            if y < 0 { y = 0 }
            else if y > 1.0 { y = 1.0 }
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
