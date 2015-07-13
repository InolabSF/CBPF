class CrimeType < ActiveHash::Base
  self.data = [
    # Violence
    { :id => 1,  :name => 'GUN',                :category => 'violence' },
    { :id => 2,  :name => 'KNIFE',              :category => 'violence' },
    { :id => 3,  :name => 'WEAPON',             :category => 'violence' },
    { :id => 4,  :name => 'FIREARM',            :category => 'violence' },
    { :id => 5,  :name => 'BATTERY',            :category => 'violence' },
    { :id => 6,  :name => 'ASSAULT',            :category => 'violence' },
    { :id => 7,  :name => 'RAPE',               :category => 'violence' },
    { :id => 8,  :name => 'SHOOTING',           :category => 'violence' },
    # Stealing vihicle
    { :id => 9,  :name => 'THEFT BICYCLE',      :category => 'stealing_vehicle' },
    { :id => 10, :name => 'STOLEN AUTO',        :category => 'stealing_vehicle' },
    { :id => 11, :name => 'STOLEN MOTOR',       :category => 'stealing_vehicle' },
    { :id => 12, :name => 'STOLEN TRUCK',       :category => 'stealing_vehicle' },
    # Traffic violation
    { :id => 13, :name => 'DRIVING',            :category => 'trafiic_violation' },
    { :id => 14, :name => 'SPEEDING',           :category => 'trafiic_violation' },
    { :id => 15, :name => 'TRAFFIC VIOLATION',  :category => 'trafiic_violation' },
    { :id => 16, :name => 'ALCOHOL',            :category => 'trafiic_violation' }
#    # Strict vehicle crimes
#    { :id =>  1, :name => 'TRAFFIC' },
#    { :id =>  2, :name => 'BICYCLE' },
#    { :id =>  3, :name => 'STOLEN' },
#    { :id =>  4, :name => 'SPEEDING' },
#    { :id =>  5, :name => 'SLASHING' },
#    # Other crimes (can now ignore these):
#    { :id =>  6, :name => 'ALCOHOL' },
#    { :id =>  7, :name => 'DRUNK' },
#    { :id =>  8, :name => 'FIREARM' },
#    { :id =>  9, :name => 'GUN' },
#    { :id =>  10, :name => 'SHOOTING' },
#    { :id =>  11, :name => 'DRUG' },
#    { :id =>  12, :name => 'STREET' },
#    { :id =>  13, :name => 'SIDEWALK' },
#    { :id =>  14, :name => 'LOITERING' },
#    { :id =>  15, :name => 'WEAPON' }
  ]
end
