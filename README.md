# CCBF

CBPF - Connected Bicycle Platform



## Documentation


<a name="sensor_type"> </a><a name="wheel_data_type"> </a>
### Server

・[REST API](http://inolabsf.github.io/CBPF/document/CCPF/server/API/)

local: http://localhost:3000

dev: https://isid-cbpf.herokuapp.com


### DB

・[SensorData Table](http://inolabsf.github.io/CBPF/document/CCPF/server/DB/SensorData.html)

・[WheelData Table](http://inolabsf.github.io/CBPF/document/CCPF/server/DB/WheelData.html)

・[CrimeData Table](http://inolabsf.github.io/CBPF/document/CCPF/server/DB/CrimeData.html)


### Data Collection

・[CrimeData Collection](http://inolabsf.github.io/CBPF/document/CCPF/DataCollection/CrimeData.html)


### Evaluation Function

・[Comfort](http://inolabsf.github.io/CBPF/document/CCPF/EvaluationFunction/Comfort.html)

・[Danger](http://inolabsf.github.io/CBPF/document/CCPF/EvaluationFunction/Danger.html)


### iOS

・~~[iOS API](http://inolabsf.github.io/CBPF/document/AirCasting/iOS/API/)~~


### Third Party

・[AirCasting private API](http://inolabsf.github.io/CBPF/document/AirCasting/server/API/)

・[SmartCitizen private API](http://inolabsf.github.io/CBPF/document/SmartCitizen/server/API/)



## Prototypes


### Visualization

・[Cluster](https://drive.google.com/file/d/0B1jHhm7QuTPRMTF0ZFVZUXhnTFU/view?usp=sharing)

・[Heat Map](https://drive.google.com/file/d/0B1jHhm7QuTPRTC1TdXZBLUROaG8/view?usp=sharing)


### Routing

・[Google Map Routing](https://drive.google.com/file/d/0B1jHhm7QuTPRUmxkUlVTZHc2dGc/view?usp=sharing) : Google Map Routings through the points that you tapped

・[Google Map Routing2](https://drive.google.com/file/d/0B1jHhm7QuTPRclhmTl9LWGdRLUU/view?usp=sharing)


## Dashboard

・[To Check Database](https://isid-cbpf.herokuapp.com/dashboard/index)


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
