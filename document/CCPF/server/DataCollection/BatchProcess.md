# Batch Process

<br />


## Method

1. Create scheduler.rake
2. Set Heroku Scheduler

<br />


## Create scheduler.rake

Write batch process codes.

```ruby
# lib/tasks/scheduler.rake

# example

desc "This task is called by the Heroku scheduler add-on"
# crime data
task :collect_crime_data => :environment do
  start_date = 3.month.ago
  end_date = 2.month.ago
  # already exist
  if CrimeData.exists?(timestamp: DateTime.new(start_date.year, start_date.month, 1)..DateTime.new(end_date.year, end_date.month, 1))
    puts 'crime data already exists'
  else
    Tasks::CrimeDataCollectionTask.execute_three_month_ago
  end
end

# environment sensor
task :collect_sensor_data => :environment do
  start_date = 3.days.ago
  end_date = 2.days.ago
  # already exist
  if SensorData.exists?(timestamp: start_date..end_date)
    puts 'sensor data already exists'
  else
    Tasks::EnvironmentSensorDataCollectionTask.execute_three_days_ago
  end
end
```

<br />


## Set Heroku Scheduler

・[Scheduler](https://devcenter.heroku.com/articles/scheduler)

<br />
