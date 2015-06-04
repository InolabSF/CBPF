import Foundation


/// MARK: - LOG

/**
 * display log
 * @param body log
 */
func HMALOG(str: String) {
#if DEBUG
    println("////////// HMA log\n" + str + "\n\n")
#endif
}

/**
 * return class name
 * @param classType classType
 * @return class name
 */
func HMANSStringFromClass(classType:AnyClass) -> String {
    let classString = NSStringFromClass(classType.self)
    let range = classString.rangeOfString(".", options: NSStringCompareOptions.CaseInsensitiveSearch, range: Range<String.Index>(start:classString.startIndex, end: classString.endIndex), locale: nil)
    return classString.substringFromIndex(range!.endIndex)
}


/// MARK: - UserDefaults

struct HMAUserDefaults {
    static let CrimeYearMonth =         "HMAUserDefaults.CrimeYearMonth"
}


/// MARK: - API

/// Base URI
#if LOCAL_SERVER
let kURIBase =                          "http://localhost:3000"
#elseif DEV_SERVER
let kURIBase =                          "https://isid-ccpf.herokuapp.com"
#else
let kURIBase =                          "https://isid-ccpf.herokuapp.com"
#endif


/// MARK: - Crime
struct HMACrime {
    /// MARK: - API
    struct API {
        static let Data = kURIBase + "/crime/data"         /// crime data API
    }
}


/// MARK: - Sensor
struct HMASensor {
    /// MARK: - type
    struct SensorType {
        static let Humidity = 1
        static let Co = 2
        static let Co2 = 3
        static let No2 = 4
        static let Pm25 = 5
        static let Noise = 6
        static let Temperature = 7
        static let Light = 8
    }

    /// MARK: - API
    struct API {
        static let Data = kURIBase + "/sensor/data"         /// sensor data API
    }
}


/// MARK: - Wheel
struct HMAWheel {
    /// MARK: - API
    struct API {
        static let Data = kURIBase + "/wheel/data"          /// wheel data API
    }
}


/// MARK: - Mapbox
struct HMAMapBox {
    /// map ID
    static let MapID =                      "kenzan8000.m4484c13"
    /// access token
    static let AccessToken =                "pk.eyJ1Ijoia2VuemFuODAwMCIsImEiOiJ3TGhnV0dvIn0.D_-l41igL-4FQWKVu4uOrA"

    /// miles for bounding box
    static let MilesForBoundingbox: Double = 12.5

    /// MARK: - Draw
    struct Draw {
        static let PixelPerMile: Double =           100.0
    }
}


/// MARK: - Google Map

/// Base URI
let kURIGoogleMapAPI =                  "https://maps.googleapis.com/maps/api"

struct HMAGoogleMap {
    /// API key
    static let APIKey =                  "AIzaSyBiJDnSOSpneOdFUtVu5RUi34rAg0cjWcU"

    /// MARK: - API
    struct API {
        static let Directions =        kURIGoogleMapAPI + "/directions/json" /// directions API
    }
}


/// MARK: - Gimbal
struct HMAGimbal {
    /// API key
    static let APIKey =                     "255f0d96-f44e-44d8-9cac-fb0445171f43"
}
