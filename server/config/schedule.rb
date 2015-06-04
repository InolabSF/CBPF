set :output, 'log/cron.log'
set :environment, :development


# crime data
every 1.month, :at => '4:00 am' do
  runner 'Tasks::CrimeDataCollectionTask.execute_three_month_ago'
end

# environment sensor
every 1.day, :at => '5:00 am' do
  runner 'Tasks:EnvironmentSensorDataCollectionTask.execute_three_days_ago'
end
