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
    static let YelpCategory =           "HMAUserDefaults.YelpCategory"
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

    /// standard crime numbers per square miles
    static let NumberPerSquareMiles: Double = 100.0

    /// reference date when iPhone searches from coredata
    static let Days =                     1
    static let MonthsAgo =                1
}


/// MARK: - Sensor
struct HMASensor {
    /// MARK: - type
    struct SensorType {
        static let None =           0
        static let Humidity =       1
        static let Co =             2
        static let Co2 =            3
        static let No2 =            4
        static let Pm25 =           5
        static let Noise =          6
        static let Temperature =    7
        static let Light =          8
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


/// MARK: - Google Map

/// Base URI
let kURIGoogleMapAPI =                  "https://maps.googleapis.com/maps/api"

struct HMAGoogleMap {
    /// API key
    static let APIKey =                 kHMAGoogleMapAPIKey
    static let BrowserAPIKey =          kHMAGoogleMapBrowserAPIKey

    /// zoom
    static let Zoom: Float =            13.0

    /// MARK: - API
    struct API {
        static let Directions =        kURIGoogleMapAPI + "/directions/json" /// directions API
        static let GeoCode =           kURIGoogleMapAPI + "/geocode/json" /// geocode API
        static let PlaceAutoComplete = kURIGoogleMapAPI + "/place/autocomplete/json" /// autocomplete API
    }

    /// MARK: - status code
    static let Status =                     "status"
    struct Statuses {
        static let OK =                     "OK"
        static let NotFound =               "NOT_FOUND"
        static let ZeroResults =            "ZERO_RESULTS"
        static let MaxWayPointsExceeded =   "MAX_WAYPOINTS_EXCEEDED"
        static let InvalidRequest =         "INVALID_REQUEST"
        static let OverQueryLimit =         "OVER_QUERY_LIMIT"
        static let RequestDenied =          "REQUEST_DENIED"
        static let UnknownError =           "UNKNOWN_ERROR"
    }

    /// MARK: - travel mode
    static let TravelMode =            "mode"
    struct TravelModes {
        static let Driving =           "driving"
        static let Walking =           "walking"
        static let Bicycling =         "bicycling"
    }

    /// MARK: - visualization
    enum Visualization {
        case None
        case Destination
        case Waypoint
        case CrimePoint
        case CrimeHeatmap
        case CrimeCluster
        case NoisePoint
        case NoiseHeatmap
        case HeatIndexPoint
        case HeatIndexHeatmap
        case Pm25Point
        case Pm25Heatmap
    }
}


/// MARK: - Yelp

struct HMAYelp {
    /// API key
    static let ConsumerKey              = kHMAYelpCosumerKey
    static let ConsumerSecret           = kHMAYelpConsumerSecret
    static let AccessToken              = kHMAYelpAccessToken
    static let AccessSecret             = kHMAYelpAccessSecret
}


/// MARK: - Gimbal

struct HMAGimbal {
    /// API key
    static let APIKey =                     kHMAGimbalAPIKey
}
