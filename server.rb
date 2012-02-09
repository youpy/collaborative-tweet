# encoding: utf-8

require './oauth_helper'
require './twitter_user'

include OAuthHelper

set :oauth_consumer_key, ENV['OAUTH_CONSUMER_KEY']
set :oauth_consumer_secret, ENV['OAUTH_CONSUMER_SECRET']
set :oauth_site, 'https://api.twitter.com/'
set :oauth_redirect_to, '/welcome'

use Rack::Csrf, :raise => true


get '/' do
  @count = Twitter::User.count()

  haml :index
end

get '/welcome' do
  access_token_key = session[:access_token_key]
  access_token_secret = session[:access_token_secret]

  access_token = OAuth::AccessToken.new(oauth_consumer, access_token_key, access_token_secret)
  data = JSON.parse(access_token.get('https://api.twitter.com/1/account/verify_credentials.json').body)
  id_str = data['id_str']

  user = Twitter::User.find_or_create_by(:id_str => id_str)
  user.key = access_token_key
  user.secret = access_token_secret
  user.save!

  flash[:msg] = 'connect to twitter'
  redirect to('/')
end

post '/update' do
  content_type :json

  result = {}

  status = params[:status] || ''

  begin
    s = update(status)

    result[:status] = 'success'
    result[:url] = 'http://twitter.com/%s/status/%i' % [s.user[:screen_name], s.id]
  rescue => e
    result[:status] = 'error'
  end

  result.to_json
end

def update(c)
  users = Twitter::User.all.sort_by { rand }

  while user = users.pop
    begin
      s = user.tweet(c,
        settings.oauth_consumer_key,
        settings.oauth_consumer_secret)

      break s
    rescue Twitter::Error::Unauthorized
      user.destroy
    end
  end
end
