class HomeController < ApplicationController
  def index
  end
  def locations
    locations = Location.all
    render json: locations.to_json
  end
end
