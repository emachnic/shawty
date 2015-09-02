require 'sinatra/config_file'

class Shawty < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'settings.yml'

  $redis = Redis.new host: settings.redis_host, port: settings.redis_port

  get '/' do
    erb :index
  end

  post '/' do
    if (params[:url] =~ URI::regexp).nil?
      @error = 'Nah man, please enter a valid URL.'
      erb :index
    else
      @token = (Time.now.to_i + rand(36**8)).to_s 36
      $redis.set "links:#{@token}", params[:url]
      erb :shortened
    end
  end

  get '/:token/?' do
    url = $redis.get "links:#{params[:token]}"
    if url.nil?
      @error = "Sorry, ain't no URL there."
    else
      redirect url
    end
  end
end

