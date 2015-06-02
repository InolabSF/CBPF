/// MARK: - constant

/// Discomfort Index
struct HMADiscomfortIndex {
    static let Cold: Double         = 55.0
    static let Chille: Double       = 57.5
    static let NotChille: Double    = 62.5
    static let Comfort: Double      = 67.5
    static let NotWarm: Double      = 72.5
    static let Warm: Double         = 77.5
    static let Hot: Double          = 82.5
    static let Boiling: Double      = 85.0
}

/// Noise Level
struct HMANoise {
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
}


/// MARK: - HMAComfort
class HMAComfort: NSObject {

    /// MARK: - property

    /// evaluation function from discomfort index
    var discomfortIndexSplineCurve: SAMCubicSpline!
    /// evaluation function from sound level
    var soundLevelSplineCurve: SAMCubicSpline!


    /// MARK: - initialization

    /**
     * Initialization
     * @return HMAComfort
     */
    override init() {
        super.init()
        self.discomfortIndexSplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Cold), 1.0)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Chille), 0.6)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.NotChille), 0.2)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Comfort), 0.0)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.NotWarm), 0.2)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Warm), 0.5)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Hot), 0.7)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMADiscomfortIndex.Boiling), 1.0)),
        ])
        self.soundLevelSplineCurve = SAMCubicSpline(points: [
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level1), 0.0)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level2), 0.05)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level3), 0.1)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level4), 0.2)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level5), 0.3)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level6), 0.5)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level7), 0.7)),
            NSValue(CGPoint: CGPointMake(CGFloat(HMANoise.Level8), 1.0)),
        ])
    }


    /// MARK: - public api

    /**
     * get longitude degree from miles
     * @param radius mile
     * @param location CLLocation
     * @return degree
     */
    func getComforts(radius: Double, location: CLLocation) -> [HMAComfort]{
        var comforts: [HMAComfort] = []
        return comforts
    }

    /**
     * get weight from evaluation function -> soundLevelSplineCurve(0.0~1.0) * discomfortIndexSplineCurve(0.0~1.0) * 100.0
     * @param comfortParameter HMAComfortParameter
     * @return weight (0 ~ 100)
     **/
    func getWeight(comfortParameter: HMAComfortParameter) -> Double {
        var valueA = Double(self.soundLevelSplineCurve.interpolate(CGFloat(comfortParameter.soundLevel)))
        var valueB = Double(self.discomfortIndexSplineCurve.interpolate(CGFloat(comfortParameter.getDiscomfortIndex())))
        if valueA < 0.0 { valueA = 0.0 }
        if valueA > 1.0 { valueA = 1.0 }
        if valueB < 0.0 { valueB = 0.0 }
        if valueB > 1.0 { valueB = 1.0 }
        return valueA * valueB * 100.0
    }

}

