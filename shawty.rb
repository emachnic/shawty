require 'rubygems'
require 'sinatra'
require 'redis'

$redis = Redis.new host: 'localhost', port: 6379

get '/' do
  erb :index
end

post '/' do
  if (params[:url] =~ URI::regexp).nil?
    @error = "Nah man, please enter a valid url."
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

  erb :index
end

__END__

@@ layout
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Shawty</title>
  </head>
  <body>
    <%= yield %>
  </body>
</html>

@@ index
<h1>Shawty</h1>
<% if @error %>
  <p><%=@error%></p>
<% end %>
<form action="/" method="post">
  <label>Enter a URL: </label>
  <br />
  <input type="url" name="url" size="40" placeholder="URL" />
  <input type="submit" value="Shorten" />
</form>

@@ shortened
<h1>Aw yeah shawty! Here's your link:</h1>
<p><a href="http://localhost:4567/<%=@token%>">http://localhost:4567/<%=@token%></a>

