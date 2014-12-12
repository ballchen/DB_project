class Location < ActiveRecord::Base
  belongs_to :place
  validates_uniqueness_of :longitude, :scope => [:latitude]
end
