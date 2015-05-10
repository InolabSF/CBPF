Rails.application.routes.draw do
  get 'sensor', :to => 'sensor#index'
  get 'sensor/data'
  post 'wheel/data'
end
