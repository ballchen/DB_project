class HomeController < ApplicationController

  def map
    @controller = 'map'
  end

  def chart
    @controller = 'chart'
  end

  def event
    @controller = 'event'
  end

  def events
    events = Event.all.to_json
    target_event = []
    ActiveSupport::JSON.decode(events).each do |event|
      if event['participant'].to_json.include?('"id":'+params[:id])
        target_event.push(event)
      end
    end
    render json: target_event
  end

  def places
    places = Place.all.to_json({:include => :location})
    target_place = []
    ActiveSupport::JSON.decode(places).each do |place|
      if place['tagged_user'].to_json.include?('"id":'+params[:id])
        target_place.push(place)
      end
    end
    render json: target_place
  end

  def locations
    locations = Location.all
    render json: locations.to_json
  end

  def likes
    likes = Like.all.to_json
    target_like = []
    ActiveSupport::JSON.decode(likes).each do |like|
      if like['liker'].to_json.include?('"id":'+params[:id])
        target_like.push(like)
      end
    end
    render json: target_like
  end

  def users
    users = User.all
    render json: users.to_json
  end
  def logout
    session[:current_user_id] = nil
    redirect_to '/'
  end
  def current_user_id
    if current_user
      render json: current_user.id
    else
      render json: nil
    end
  end


  def all_events
    events = Event.all.to_json
    render json: events
  end
  def all_places
    places = Place.all.to_json({:include => :location})
    render json: places
  end
  def all_likes
    likes = Like.all.to_json
    render json: likes
  end

end
