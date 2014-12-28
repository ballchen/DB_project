class User < ActiveRecord::Base
  validates_uniqueness_of :data_id
  def clean_like
    likes = []
    self.likes.each do |like|
      if !likes.to_json.include?(like.to_json)
        likes.push(like)
      end
    end
    self.likes = likes
  end
  def education
    self.schools.last['name'] + " " + self.majors.last['name']
  end
end
