class CrimeType < ActiveHash::Base
  self.data = [
    # Strict vehicle crimes
    { :id =>  1, :name => 'TRAFFIC' },
    { :id =>  2, :name => 'BICYCLE' },
    { :id =>  3, :name => 'STOLEN' },
    { :id =>  4, :name => 'SPEEDING' },
    { :id =>  5, :name => 'SLASHING' },
    # Other crimes (can now ignore these):
    { :id =>  6, :name => 'ALCOHOL' },
    { :id =>  7, :name => 'DRUNK' },
    { :id =>  8, :name => 'FIREARM' },
    { :id =>  9, :name => 'GUN' },
    { :id =>  10, :name => 'SHOOTING' },
    { :id =>  11, :name => 'DRUG' },
    { :id =>  12, :name => 'STREET' },
    { :id =>  13, :name => 'SIDEWALK' },
    { :id =>  14, :name => 'LOITERING' },
    { :id =>  15, :name => 'WEAPON' }
  ]
end
