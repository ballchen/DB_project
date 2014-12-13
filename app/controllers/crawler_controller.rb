require 'rest-more'
require 'net/http'
class CrawlerController < ApplicationController
  def get_access_token
    if Rails.env.development?
      app_id = '718004254957012'
      secret = '90c8fab3937966611b07e751ae6d6aa4'
      redirect_uri = 'http://localhost:3000/auth'
    elsif Rails.env.production?
      app_id = '717959514961486'
      secret =  'e9e7630ba3c7ba9138212ef6bfd236cb'
      redirect_uri = 'http://peaceful-springs-2884.herokuapp.com/auth'
    end
    f = RC::Facebook.new :app_id => app_id,
                         :secret => secret,
                         :log_method => method(:puts)
    scope = 'public_profile, user_likes, user_status, user_tagged_places'

    # Redirect the user to:
    redirect_to f.authorize_url(:redirect_uri => redirect_uri, :scope => scope)


    # Then we could call the API:
  end
  def auth
    if Rails.env.development?
      app_id = '718004254957012'
      secret = '90c8fab3937966611b07e751ae6d6aa4'
      redirect_uri = 'http://localhost:3000/auth'
    elsif Rails.env.production?
      app_id = '717959514961486'
      secret =  'e9e7630ba3c7ba9138212ef6bfd236cb'
      redirect_uri = 'http://peaceful-springs-2884.herokuapp.com/auth'
    end
    f = RC::Facebook.new :app_id => app_id,
                     :secret => secret,
                     :log_method => method(:puts)
    scope = 'public_profile, user_likes, user_status, user_tagged_places'
    f.authorize!(:redirect_uri => redirect_uri, :code => params[:code])
    raw_data = f.get('me/statuses?fields=tags.limit(500){pic,name,id},place,message&offset=0&limit=500')
    info = []
    get_place_from_status(raw_data,info)
    raw_data = f.get('me/tagged_places?field=place')
    get_place_from_tagged_places(raw_data,info)
    raw_data = f.get('me/likes')
    get_data_from_likes(raw_data,info)
    @location = Location.all
    @place = Place.all
    @like = Like.all
    render json: {location: @location, place: @place, like: @like}
  end

  private
  def get_data_from_place_object(data)
      place = Place.find_or_create_by(data_id: data['place']['id'].to_i)
      place.data_id = data['place']['id'].to_i
      place.name = data['place']['name']
      place.updated_time = data['updated_time']
      place.message = data['message']
      if(place.tagged_user==nil)
           place.tagged_user = []
      end
      data['tags']['data'].each do |tag|
        user = User.find_or_create_by(data_id: tag['id'].to_i)
        user.pic = tag['pic']
        user.name = tag['name']
        if(user.been_to==nil)
          user.been_to = []
        end
        user.been_to.push({
          id: place.id,
          place: {
            name: place.name,
            message: place.message
            }
          })
        user.save
        place.tagged_user.push({
          id: user.id,
          user: {
            pic: user.pic,
            name: user.name
          }
          })
      end
      location = Location.new
      location.city = data['place']['location']['city']
      location.country = data['place']['location']['country']
      location.latitude = data['place']['location']['latitude']
      location.longitude = data['place']['location']['longitude']
      location.street = data['place']['location']['street']
      location.zip = data['place']['location']['zip']
      location.save
      place.location_id = location.id
      place.save
  end

  def get_place_from_tagged_places(raw_data,info)
    raw_data['data'].each do | data |
      if(data['place'])
        get_data_from_place_object(data)
      end
    end
    if( raw_data['paging'] && raw_data['paging']['next'] )
      raw_data = ActiveSupport::JSON.decode Net::HTTP.get(URI.parse(raw_data['paging']['next']))
      get_place_from_tagged_places(raw_data,info)
    end
  end

  def get_place_from_status(raw_data,info)
    raw_data['data'].each do | data |
      if(data['place'])
        place = Place.new
        place.data_id = data['place']['id'].to_i
        place.name = data['place']['name']
        place.updated_time = data['updated_time']
        location = Location.new
        location.city = data['place']['location']['city']
        location.country = data['place']['location']['country']
        location.latitude = data['place']['location']['latitude']
        location.longitude = data['place']['location']['longitude']
        location.street = data['place']['location']['street']
        location.zip = data['place']['location']['zip']
        location.save
        place.location_id = location.id
        place.save
      end
    end
    if( raw_data['paging'] && raw_data['paging']['next'] )
      raw_data = ActiveSupport::JSON.decode Net::HTTP.get(URI.parse(raw_data['paging']['next']))
      get_place_from_status(raw_data,info)
    end
  end

  def get_data_from_likes(raw_data,info)
    raw_data['data'].each do | data |
      like = Like.new
      like.category = data['category']
      like.name = data['name']
      like.created_time = data['created_time']
      like.data_id = data['id'].to_i
      like.save
    end
    if( raw_data['paging'] && raw_data['paging']['next'] )
      raw_data = ActiveSupport::JSON.decode Net::HTTP.get(URI.parse(raw_data['paging']['next']))
      get_data_from_likes(raw_data,info)
    end
  end

end
