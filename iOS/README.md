# iOS App


## Installation

##### 1. Clone and install Pods

```
git clone https://github.com/InolabSF/CBPF.git
cd CBPF
pod install
```

##### 2. Register Google Developer Console

https://console.developers.google.com/

- Request credential
 - browser key
 - ios key

- Enable APIs
 - Directions API
 - Distance Matrix API
 - Elevation API
 - Geocoding API
 - Google Maps Engine API
 - Google Maps SDK for iOS
 - Google Places API for iOS
 - Google Places API Web Service
 - Time Zone API

- Check your api keys
 - browser key
 - iOS key

##### 3. Register Mapbox Developer

https://www.mapbox.com/

- Create project

- Check your project and access token
 - project's map ID
 - API access token


##### 4. Add /Destination Alarm/Classes/DAConstant-Private.swift

```swift
/// Google Map API key
let kHMAGoogleMapAPIKey =               "YOUR_GOOGLE_MAP_IOS_APP_API_KEY"
let kHMAGoogleMapBrowserAPIKey =        "YOUR_GOOGLE_MAP_BROWSER_APP_API_KEY"

/// Mapbox Map ID
let kHMAMapboxMapID =                   "YOUR_MAPBOX_MAP_ID"
let kHMAMapboxAccessToken =             "YOUR_MAPBOX_ACCESS_TOKEN"
```
