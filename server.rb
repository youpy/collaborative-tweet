require './oauth_helper'

include OAuthHelper

set :oauth_consumer_key, ENV['OAUTH_CONSUMER_KEY']
set :oauth_consumer_secret, ENV['OAUTH_CONSUMER_SECRET']
set :oauth_site, ''
set :oauth_redirect_to, '/welcome'

get '/' do
  haml :index
end

get '/welcome' do
  #access_token_key = session[:access_token_key]
  #access_token_secret = session[:access_token_secret]
  #access_token = OAuth::AccessToken.new(oauth_consumer, access_token_key, access_token_secret)
  haml :welcome
end
