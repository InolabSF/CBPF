set :output, 'log/cron.log'
set :environment, :development


every 1.day, :at => '5:00 am' do
  runner 'Tasks:EnvironmentSensorDataCollectionTask.execute'
end
