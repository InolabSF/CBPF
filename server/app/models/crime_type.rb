class CrimeType < ActiveHash::Base
  self.data = [
    # Violence
    { :id => 1, :name => 'GUN' },
    { :id => 2, :name => 'KNIFE' },
    { :id => 3, :name => 'WEAPON' },
    { :id => 4, :name => 'FIREARM' },
    { :id => 5, :name => 'BATTERY' },
    { :id => 6, :name => 'ASSAULT' },
    { :id => 7, :name => 'RAPE' },
    { :id => 8, :name => 'SHOOTING' },
    # Stealing vihicle
    { :id => 9, :name => 'THEFT BICYCLE' },
    { :id => 10, :name => 'STOLEN AUTO' },
    { :id => 11, :name => 'STOLEN MOTOR' },
    { :id => 12, :name => 'STOLEN TRUCK' },
    # Traffic accident
    { :id => 13, :name => 'DRIVING' },
    { :id => 14, :name => 'SPEEDING' },
    { :id => 15, :name => 'TRAFFIC VIOLATION' },
    { :id => 16, :name => 'ALCOHOL' }
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
