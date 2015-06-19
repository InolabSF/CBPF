Rails.application.routes.draw do
  get 'sensor/data'
  get 'wheel/data'
  get 'wheel/location'
  get 'wheel/accel'
  get 'wheel/torque'
  get 'wheel/accel_torque'
  post 'wheel/data'
  get 'crime/data'
  get 'dashboard/index'
end
