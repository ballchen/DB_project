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
    raw_data = f.get(URI.encode('me?fields=name,picture.width(1000)'))
    current_user = get_user(raw_data)
    raw_data = f.get(URI.encode('me/statuses?fields=tags.limit(500){pic,name,id},place,message&limit=500'))
    get_place_from_status(raw_data,current_user)
    raw_data = f.get(URI.encode('me/tagged_places?field=place&limit=500'))
    get_place_from_tagged_places(raw_data,current_user)
    # raw_data = f.get(URI.encode('me/likes?limit=500'))
    # get_data_from_likes(raw_data,current_user)
    @location = Location.all
    @place = Place.all
    @like = Like.all
    @user = User.all
    render json: {location: @location, place: @place, like: @like,user: @user}
  end

  private
  def get_user raw_data
    user = User.find_or_create_by(data_id: raw_data['id'].to_i)
    user.name = raw_data['name']
    if raw_data['picture']
      user.pic = raw_data['picture']['data']['url']
    end
    user.save
    user
  end
  def get_data_from_place_object(data,current_user)
    place = Place.find_or_create_by(data_id: data['place']['id'].to_i)
    place.data_id = data['place']['id'].to_i
    place.name = (data['place']['name'] == nil)? place.name : data['place']['name']
    place.updated_time = (data['updated_time'] == nil)? place.updated_time : data['updated_time']
    place.message = (data['message'] == nil)? place.message : data['message']
    if(place.tagged_user==nil)
      place.tagged_user = []
    end
    if( current_user.been_to==nil)
      current_user.been_to = []
    end
    place_json = {
      id: place.id,
      place: {
        name: place.name,
        message: place.message
      }
    }
    if !current_user.been_to.to_json.include?(place_json.to_json)
      current_user.been_to.push(place_json)
    end
    current_user_json = {
      id: current_user.id,
      user: {
        pic: current_user.pic,
        name: current_user.name
      }
    }
    if !place.tagged_user.to_json.include?(current_user_json.to_json)
      place.tagged_user.push(current_user_json)
    end
    if data['tags'] != nil
      data['tags']['data'].each do |tag|
        user = User.find_or_create_by(data_id: tag['id'].to_i)
        user.pic = tag['pic']
        user.name = tag['name']
        if(user.been_to==nil)
          user.been_to = []
        end
        if !user.been_to.to_json.include?(place_json.to_json)
          user.been_to.push(place_json)
        end
        user_json = {
          id: user.id,
          user: {
            pic: user.pic,
            name: user.name
          }
        }
        if !place.tagged_user.to_json.include?(user_json.to_json)
          place.tagged_user.push(user_json)
        end
        user.been_to = user.been_to.to_json
        user.save
      end
    end
    conditions = { :latitude => data['place']['location']['latitude'],
                   :longitude => data['place']['location']['longitude']
                   }
    location = Location.where(conditions).first_or_create
    location.city = data['place']['location']['city']
    location.country = data['place']['location']['country']
    location.latitude = data['place']['location']['latitude']
    location.longitude = data['place']['location']['longitude']
    location.street = data['place']['location']['street']
    location.zip = data['place']['location']['zip']
    location.save
    place.location_id = location.id
    current_user.been_to = current_user.been_to.to_json
    current_user.save
    place.tagged_user = place.tagged_user.to_json
    place.save
  end

  def paring_likes(data,current_user)
    like = Like.find_or_create_by(data_id: data['id'].to_i)
    like.category = data['category']
    like.name = data['name']
    like.created_time = data['created_time']
    like.data_id = data['id'].to_i
    if (current_user.likes == nil)
      current_user.likes = []
    end
    like_json = {
      id: like.id,
      like: {
        name: like.name
      }
    }
    if !current_user.likes.to_json.include?(like_json.to_json.to_json)
      current_user.likes.push(like_json)
      current_user.likes = current_user.likes.to_json
      current_user.save
    end
    if (like.liker ==nil)
      like.liker = []
    end
    current_user_json ={
      id: current_user.id,
      user: {
        pic: current_user.pic,
        name: current_user.name
      }
    }
    if !like.liker.to_json.include?(current_user_json.to_json)
      like.liker.push(current_user_json)
      like.liker = like.liker.to_json
      like.save
    end
  end

  def get_place_from_tagged_places(raw_data,current_user)
    raw_data['data'].each do | data |
      if(data['place'])
        get_data_from_place_object(data, current_user)
      end
    end
    if( raw_data['paging'] && raw_data['paging']['next'] )
      raw_data = ActiveSupport::JSON.decode Net::HTTP.get(URI.parse(raw_data['paging']['next']))
      get_place_from_tagged_places(raw_data,current_user)
    end
  end

  def get_place_from_status(raw_data,current_user)
    raw_data['data'].each do | data |
      if(data['place'])
        get_data_from_place_object(data,current_user)
      end
    end
    if( raw_data['paging'] && raw_data['paging']['next'] )
      raw_data = ActiveSupport::JSON.decode Net::HTTP.get(URI.parse(raw_data['paging']['next']))
      get_place_from_status(raw_data,current_user)
    end
  end

  def get_data_from_likes(raw_data,current_user)
    raw_data['data'].each do | data |
      paring_likes(data,current_user)
    end
    if( raw_data['paging'] && raw_data['paging']['next'] )
      raw_data = ActiveSupport::JSON.decode Net::HTTP.get(URI.parse(raw_data['paging']['next']))
      get_data_from_likes(raw_data,current_user)
    end
  end

end
