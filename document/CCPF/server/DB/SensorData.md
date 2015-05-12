# Sensor Data Table

<br />

## Entity

| id      | sensor_id | value | lat   | long  | user_id | timestamp |
|---------|-----------|-------|-------|-------|---------|-----------|
| Integer | Integer   | Float | Float | Float | Integer | DateTime  |

<br />

## Attributes

### sensor_id

sensor id -> ~~[foreign key](http://kenzan8000.github.io/CCPF/document/CCPF/server/DB/SensorTable.html)~~

### value

data value that we can get from environmental sensor

### lat

latitude when the data is gotten

### long

longitude when the data is gotten

### user_id

user id -> ~~[foreign key](http://kenzan8000.github.io/CCPF/document/CCPF/server/DB/UserTable.html)~~

### timestamp

timestamp when the data is gotten
