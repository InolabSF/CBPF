### generate model
```
# example
$ rails generate model SensorData sensor_id:integer value:float lat:float long:float user_id:integer timestamp:datetime
```

### migration
```
$ rake db:migrate
```

### generate controller
```
# example
rails generate controller YOUR_CONTROLLER_NAME
```

### manual cron
```
# example (local)
$ rails runner Tasks::EnvironmentSensorDataCollectionTask.executeAll
$ rails runner Tasks::CrimeDataCollectionTask.executeThreeMonthAgo
# example (heroku)
$ heroku run rails runner Tasks::EnvironmentSensorDataCollectionTask.executeThreeDaysAgo
$ heroku run rails runner Tasks::CrimeDataCollectionTask.executeThreeMonthAgo
```

### automatical cron
```
# register
$ bundle exec whenever --update-crontab

# delete
$ bundle exec whenever --clear-crontab
```

### sensor data API
```
# example
http://localhost:3000/sensor/data?lat=37.76681832250885&long=-122.4207906162038
```

#### create app on Heroku
```
$ bundle exec heroku create YOUR_APP
```

#### PostgreSQL setting
```
$ heroku addons:add heroku-postgresql --app YOUR_APP
$ heroku config --app YOUR_APP
=== herokuapp Config Vars
DATABASE_URL:                  postgres://〜
HEROKU_POSTGRESQL_(COLOR)_URL: postgres://〜
....
$ heroku pg:promote HEROKU_POSTGRESQL_(COLOR)_URL --app YOUR_APP
```

#### deploy Heroku
```
$ git push heroku master
$ heroku run rake db:migrate
$ bundle exec heroku open
```
