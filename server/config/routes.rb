Rails.application.routes.draw do
  get 'sensor/data'
  get 'wheel/data'
  post 'wheel/data'
end
