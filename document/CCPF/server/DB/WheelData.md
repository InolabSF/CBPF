# Wheel Data Table

<br />

## Entity

| id      | data_type | value | lat   | long  | timestamp |
|---------|-----------|-------|-------|-------|-----------|
| Integer | Integer   | Float | Float | Float | DateTime  |

<br />

## Attributes

### id

id

### type

data type that we can get from copenhagen wheel

##### _example_

| type | description |
|------|-------------|
| 1 |  sensorData.phone.applicationState |
| 2 |  sensorData.phone.altitude |
| 3 |  sensorData.phone.networkState |
| 4 |  sensorData.phone.speed |
| 5 |  sensorData.phone.gpsHorizontalAccuracy |
| 6 |  sensorData.phone.gpsVerticalAccuracy |
| 7 |  sensorData.phone.batteryLevel |
| 8 |  sensorData.phone.gpsStrength |
| 9 |  wheelData.speed |
| 10 | wheelData.slope |
| 11 | wheelData.energyEfficiency |
| 12 | wheelData.totalOdometer |
| 13 | wheelData.tripOdometer |
| 14 | wheelData.tripAverageSpeed |
| 15 | wheelData.tripEnergyEfficiency |
| 16 | wheelData.motorTemperature |
| 17 | wheelData.motorDriveTemperature |
| 18 | wheelData.riderTorque |
| 19 | wheelData.riderPower |
| 20 | wheelData.batteryCharge |
| 21 | wheelData.batteryHealth |
| 22 | wheelData.batteryPower |
| 23 | wheelData.batteryVoltage |
| 24 | wheelData.batteryCurrent |
| 25 | wheelData.batteryTemperature |
| 26 | wheelData.batteryTimeToFull |
| 27 | wheelData.batteryTimeToEmpty |
| 28 | wheelData.batteryRange |
| 29 | wheelData.rawDebugData |
| 30 | wheelData.batteryPowerNormalized |
| 31 | wheelData.acceleration |

### value

data value that we can get from copenhagen wheel

### lat

latitude when the data is gotten

### long

longitude when the data is gotten

### user_id

user id -> ~~[foreign key](http://kenzan8000.github.io/CCPF/document/CCPF/server/DB/UserTable.html)~~

### timestamp

timestamp when the data is gotten
