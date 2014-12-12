class Place < ActiveRecord::Base
  has_one :location
  validates_uniqueness_of :data_id
end
