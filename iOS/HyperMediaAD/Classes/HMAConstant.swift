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


/// MARK: - API

/// Base URI
#if LOCAL_SERVER
let kURIBase =                          "http://localhost:3000"
#elseif DEV_SERVER
let kURIBase =                          "https://isid-ccpf.herokuapp.com"
#else
let kURIBase =                          "https://isid-ccpf.herokuapp.com"
#endif


/// MARK: - sensor

/// sensor data API
let kURISensorData =                    kURIBase + "/sensor/data"


/// MARK: - Mapbox

/// access token
let kMapboxAccessToken =                "pk.eyJ1Ijoia2VuemFuODAwMCIsImEiOiJ3TGhnV0dvIn0.D_-l41igL-4FQWKVu4uOrA"


/// MARK: - Google Map

/// API key
let kGoogleMapAPIKey =                  "AIzaSyBiJDnSOSpneOdFUtVu5RUi34rAg0cjWcU"


/// MARK: - Gimbal

/// API key
let kGimbalAPIKey =                     "255f0d96-f44e-44d8-9cac-fb0445171f43"
