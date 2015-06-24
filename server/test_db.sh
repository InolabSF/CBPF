#!/bin/bash

rm db/development.sqlite3

rake db:migrate

rails runner Tasks::EnvironmentSensorDataCollectionTask.execute_all
rails runner Tasks::CrimeDataCollectionTask.execute_three_month_ago
rails runner Tasks::WheelLocationCollectionTask.execute
rails runner Tasks::WheelDataCollectionTask.execute
