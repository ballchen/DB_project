class HomeController < ApplicationController
  def index
  end
  def locations
    locations = Place.all
    render json: locations.to_json({:include => :location})
  end
end
