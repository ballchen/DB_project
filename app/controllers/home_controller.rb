class HomeController < ApplicationController
  def index
    @controller = 'map'
  end
  def chart
    @controller = 'chart'
  end
  def event
    @controller = 'event'
  end

  def events
    event = Event.all
    render json: event.to_json
  end
  def places
    places = Place.all
    render json: places.to_json({:include => :location})
  end
  def locations
    locations = Location.all
    render json: locations.to_json
  end
  def likes
    likes = Like.all
    render json: likes.to_json
  end
  def users
    users = User.all
    render json: users.to_json
  end
end
