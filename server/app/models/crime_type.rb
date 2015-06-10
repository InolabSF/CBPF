class CrimeType < ActiveHash::Base
  self.data = [
    # Strict vehicle crimes
    { :id =>  1, :name => 'TRAFFIC' },
    { :id =>  2, :name => 'VEHICLE' },
    { :id =>  3, :name => 'BICYCLE' },
    { :id =>  4, :name => 'AUTO' },
    { :id =>  5, :name => 'MOTORCYCLE' },
    { :id =>  6, :name => 'TRUCK' },
    { :id =>  7, :name => 'TAXI' },
    { :id =>  8, :name => 'DRIVER' },
    { :id =>  9, :name => 'SPEEDING' },
    { :id => 10, :name => 'TIRE' },
    { :id => 11, :name => 'DRIVING' },
    { :id => 12, :name => 'DISTURB' },
    #{ :id => 12, :name => 'DISTURB' }
    # Other crimes (can now ignore these):
    { :id => 13, :name => 'LICENSE' },
    { :id => 14, :name => 'ALCOHOL' },
    { :id => 15, :name => 'DRUNK' },
    { :id => 16, :name => 'FIREARM' },
    { :id => 17, :name => 'GUN' },
    { :id => 18, :name => 'SHOOTING' },
    { :id => 19, :name => 'DRUG' },
    { :id => 20, :name => 'MISCHIEF' },
    { :id => 21, :name => 'ATM' },
    { :id => 22, :name => 'MANNER' },
    { :id => 23, :name => 'INDECENT' },
    { :id => 24, :name => 'STREET' },
    { :id => 25, :name => 'SIDEWALK' },
    { :id => 26, :name => 'OBSTRUCTING' },
    { :id => 27, :name => 'LOITERING' },
    { :id => 28, :name => 'PEDDLING' },
    { :id => 29, :name => 'PARK' }
  ]
end
