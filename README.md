# CCBF

CBPF - Connected Bicycle Platform



## Documentation


<a name="sensor_type"> </a><a name="wheel_data_type"> </a>
### Server

##### REST API

・[REST API](http://inolabsf.github.io/CBPF/document/CCPF/server/API/)

local: http://localhost:3000

dev: https://connected-bicycle-platform.herokuapp.com


##### DB

・[SensorData Table](http://inolabsf.github.io/CBPF/document/CCPF/server/DB/SensorData.html)

・[CrimeData Table](http://inolabsf.github.io/CBPF/document/CCPF/server/DB/CrimeData.html)

・[WheelData Table](http://inolabsf.github.io/CBPF/document/CCPF/server/DB/WheelData.html)


##### Data Collection

・[Batch Process](http://inolabsf.github.io/CBPF/document/CCPF/server/DataCollection/BatchProcess.html)

・[SensorData Collection](http://inolabsf.github.io/CBPF/document/CCPF/server/DataCollection/SensorData.html)

・[CrimeData Collection](http://inolabsf.github.io/CBPF/document/CCPF/server/DataCollection/CrimeData.html)


### iOS

##### iPhone

・~~[iOS API](http://inolabsf.github.io/CBPF/document/AirCasting/iOS/API/)~~

##### Evaluation Function

・[Comfort](http://inolabsf.github.io/CBPF/document/CCPF/iOS/EvaluationFunction/Comfort.html)


#### Third Party

・[AirCasting private API](http://inolabsf.github.io/CBPF/document/AirCasting/server/API/)

・[SmartCitizen private API](http://inolabsf.github.io/CBPF/document/SmartCitizen/server/API/)

・[SF OpenData](https://data.sfgov.org/developers)



## Prototypes

### Visualization

・[Cluster](https://drive.google.com/file/d/0B1jHhm7QuTPRMTF0ZFVZUXhnTFU/view?usp=sharing)

・[Heat Map](https://drive.google.com/file/d/0B1jHhm7QuTPRTC1TdXZBLUROaG8/view?usp=sharing)


### Routing

・[Google Map Routing](https://drive.google.com/file/d/0B1jHhm7QuTPRUmxkUlVTZHc2dGc/view?usp=sharing) : Google Map Routings through the points that you tapped

・[Google Map Routing2](https://drive.google.com/file/d/0B1jHhm7QuTPRclhmTl9LWGdRLUU/view?usp=sharing)



## Dashboard

・[To Check Database](https://connected-bicycle-platform.herokuapp.com/dashboard/index)



## Sensor and Wheel Data

### Server

Environmental sensor types that CBPF server provides from [Server REST API](#sensor_type).
```
Sensor > Parameter > sensor_type
e.g. humidity, co, co2, no2, pm25, noise, temperature, light, etc
```

Wheel data types that  CBPF server provides from [Server REST API](#wheel_data_type).
```
Wheel > Parameter > data_type
e.g. wheelData_speed, wheelData_slope, wheelData_energyEfficiency, wheelData_totalOdometer, etc
```
