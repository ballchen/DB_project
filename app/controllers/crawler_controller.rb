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
    raw_data = f.get('me/statuses?fields=place')
    info = []
    get_place_from_status(raw_data,info)
    raw_data = f.get('me/tagged_places?field=place')
    get_place_from_tagged_places(raw_data,info)
    raw_data = f.get('me/likes')
    get_data_from_likes(raw_data,info)
    render json: info
  end

  private
  def get_json(object)
    ActiveSupport::JSON.decode(object)
  end

  def get_place_from_tagged_places(raw_data,info)
    raw_data['data'].each do | data |
      if(data['place'])
        info.push(data)
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
        info.push(data)
      end
    end
    if( raw_data['paging'] && raw_data['paging']['next'] )
      raw_data = ActiveSupport::JSON.decode Net::HTTP.get(URI.parse(raw_data['paging']['next']))
      get_place_from_status(raw_data,info)
    end
  end

  def get_data_from_likes(raw_data,info)
    raw_data['data'].each do | data |
      info.push(data)
    end
    if( raw_data['paging'] && raw_data['paging']['next'] )
      raw_data = ActiveSupport::JSON.decode Net::HTTP.get(URI.parse(raw_data['paging']['next']))
      get_data_from_likes(raw_data,info)
    end
  end

end
