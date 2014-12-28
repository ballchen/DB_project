class User < ActiveRecord::Base
  validates_uniqueness_of :data_id
  def education
    self.schools.last['name'] + " " + self.majors.last['name']
  end
end
