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
    /// crime
    static let CrimeYearMonth =                                 "HMAUserDefaults.CrimeYearMonth"
    /// sensor
    static let SensorHumidityYearMonthDay =                     "HMAUserDefaults.SensorHumidityYearMonthDay"
    static let SensorCoYearMonthDay =                           "HMAUserDefaults.SensorCoYearMonthDay"
    static let SensorCo2YearMonthDay =                          "HMAUserDefaults.SensorCo2YearMonthDay"
    static let SensorNo2YearMonthDay =                          "HMAUserDefaults.SensorNo2YearMonthDay"
    static let SensorPm25YearMonthDay =                         "HMAUserDefaults.SensorPm25YearMonthDay"
    static let SensorNoiseYearMonthDay =                        "HMAUserDefaults.SensorNoiseYearMonthDay"
    static let SensorTemperatureYearMonthDay =                  "HMAUserDefaults.SensorTemperatureYearMonthDay"
    static let SensorLightYearMonthDay =                        "HMAUserDefaults.CrimeYearMonth"
    /// wheel
    static let WheelSpeedYearMonthDay =                         "HMAUserDefaults.WheelSpeedYearMonthDay"
    static let WheelSlopeYearMonthDay =                         "HMAUserDefaults.WheelSlopeYearMonthDay"
    static let WheelEnergyEfficiencyYearMonthDay =              "HMAUserDefaults.WheelEnergyEfficiencyYearMonthDay"
    static let WheelTotalOdometerYearMonthDay =                 "HMAUserDefaults.WheelTotalOdometerYearMonthDay"
    static let WheelTripOdometerYearMonthDay =                  "HMAUserDefaults.WheelTripOdometerYearMonthDay"
    static let WheelTripAverageSpeedYearMonthDay =              "HMAUserDefaults.WheelTripAverageSpeedYearMonthDay"
    static let WheelTripEnergyEfficiencyYearMonthDay =          "HMAUserDefaults.WheelTripEnergyEfficiencyYearMonthDay"
    static let WheelMotorTemperatureYearMonthDay =              "HMAUserDefaults.WheelMotorTemperatureYearMonthDay"
    static let WheelMotorDriveTemperatureYearMonthDay =         "HMAUserDefaults.WheelMotorDriveTemperatureYearMonthDay"
    static let WheelRiderTorqueYearMonthDay =                   "HMAUserDefaults.WheelRiderTorqueYearMonthDay"
    static let WheelRiderPowerYearMonthDay =                    "HMAUserDefaults.WheelRiderPowerYearMonthDay"
    static let WheelBatteryChargeYearMonthDay =                 "HMAUserDefaults.WheelBatteryChargeYearMonthDay"
    static let WheelBatteryHealthYearMonthDay =                 "HMAUserDefaults.WheelBatteryHealthYearMonthDay"
    static let WheelBatteryPowerYearMonthDay =                  "HMAUserDefaults.WheelBatteryPowerYearMonthDay"
    static let WheelBatteryVoltageYearMonthDay =                "HMAUserDefaults.WheelBatteryVoltageYearMonthDay"
    static let WheelBatteryCurrentYearMonthDay =                "HMAUserDefaults.WheelBatteryCurrentYearMonthDay"
    static let WheelBatteryTemperatureYearMonthDay =            "HMAUserDefaults.WheelBatteryTemperatureYearMonthDay"
    static let WheelBatteryTimeToFullYearMonthDay =             "HMAUserDefaults.WheelBatteryTimeToFullYearMonthDay"
    static let WheelBatteryTimeToEmptyYearMonthDay =            "HMAUserDefaults.WheelBatteryTimeToEmptyYearMonthDay"
    static let WheelBatteryRangeYearMonthDay =                  "HMAUserDefaults.WheelBatteryRangeYearMonthDay"
    static let WheelRawDebugDataYearMonthDay =                  "HMAUserDefaults.WheelRawDebugDataYearMonthDay"
    static let WheelBatteryPowerNormalizedYearMonthDay =        "HMAUserDefaults.WheelBatteryPowerNormalizedYearMonthDay"
    static let WheelAccelerationYearMonthDay =                  "HMAUserDefaults.WheelAccelerationYearMonthDay"
    /// yelp
    static let YelpCategory =                                   "HMAUserDefaults.YelpCategory"
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


/// MARK: - HMAAPI

struct HMAAPI {
    /// the furthest distance that client requests server to get datas
    static let Radius: Float = 50.0
}


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

    /// MARK: - dataType
    struct DataType {
        static let Speed =                              9
        static let Slope =                              10
        static let EnergyEfficiency =                   11
        static let TotalOdometer =                      12
        static let TripOdometer =                       13
        static let TripAverageSpeed =                   14
        static let TripEnergyEfficiency =               15
        static let MotorTemperature =                   16
        static let MotorDriveTemperature =              17
        static let RiderTorque =                        18
        static let RiderPower =                         19
        static let BatteryCharge =                      20
        static let BatteryHealth =                      21
        static let BatteryPower =                       22
        static let BatteryVoltage =                     23
        static let BatteryCurrent =                     24
        static let BatteryTemperature =                 25
        static let BatteryTimeToFull =                  26
        static let BatteryTimeToEmpty =                 27
        static let BatteryRange =                       28
        static let RawDebugData =                       29
        static let BatteryPowerNormalized =             30
        static let Acceleration =                       31
    }

    /// max value when client requests to get datas from server
    struct Max {
        static let Acceleration: Float =                      -2.0
    }

    /// min value when client requests to get datas from server
    struct Min {
        static let RiderTorque: Float =                       12.0
    }

    /// max distance for visualization (miles)
    static let MaxDistanceForVisualization: Double =           0.08
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
}


/// MARK: - Yelp

struct HMAYelp {
    /// API key
    static let ConsumerKey              = kHMAYelpCosumerKey
    static let ConsumerSecret           = kHMAYelpConsumerSecret
    static let AccessToken              = kHMAYelpAccessToken
    static let AccessSecret             = kHMAYelpAccessSecret

    // restaurant category
    static let Restaurants = [
        "african" : "restaurants",
        "brazilian" : "restaurants",
        "caribbean" : "restaurants",
        "chinese" : "restaurants",
        "donburi" : "restaurants",
        "ethiopian" : "restaurants",
        "french" : "restaurants",
        "german" : "restaurants",
        "italian" : "restaurants",
        "japanese" : "restaurants",
        "latin" : "restaurants",
        "malaysian" : "restaurants",
        "mediterranean" : "restaurants",
        "mexican" : "restaurants",
        "mideastern" : "restaurants",
        "polish" : "restaurants",
        "vietnamese" : "restaurants",
        "portuguese" : "restaurants",
        "spanish" : "restaurants",
        "turkish" : "restaurants",
    ]
}


/// MARK: - Gimbal

struct HMAGimbal {
    /// API key
    static let APIKey =                     kHMAGimbalAPIKey
}
