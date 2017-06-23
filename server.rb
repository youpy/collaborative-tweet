# encoding: utf-8

require './collaborator'

set :oauth_consumer_key, ENV['OAUTH_CONSUMER_KEY']
set :oauth_consumer_secret, ENV['OAUTH_CONSUMER_SECRET']
set :oauth_site, 'https://api.twitter.com/'
set :oauth_redirect_to, '/welcome'

enable :sessions
set :session_secret, ENV['CT_SESSION_SECRET'] || 'Niu3cksBHew0v7etUKh7tM4AMR'

use Rack::Csrf, :raise => true

get '/' do
  @count = Collaborator.count()
  @text = params[:text] || ''

  haml :index
end

get '/welcome' do
  access_token_key = session[:access_token_key]
  access_token_secret = session[:access_token_secret]

  access_token = OAuth::AccessToken.new(oauth_consumer, access_token_key, access_token_secret)
  data = JSON.parse(access_token.get('https://api.twitter.com/1.1/account/verify_credentials.json').body)
  id_str = data['id_str']

  user = Collaborator.find_or_create_by(:id_str => id_str)
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
  end

  result.to_json
end

get '/oauth/auth' do
  request_token = oauth_consumer.get_request_token(:oauth_callback => url('/oauth/cb'))
  session[:request_token] = request_token
  redirect request_token.authorize_url
end

get '/oauth/cb' do
  access_token = session[:request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
  session[:access_token_key] = access_token.token
  session[:access_token_secret] = access_token.secret
  session.delete(:request_token)
  redirect to(settings.oauth_redirect_to)
end

def oauth_consumer
  OAuth::Consumer.new(
    settings.oauth_consumer_key,
    settings.oauth_consumer_secret,
    {
      :site => settings.oauth_site,
    })
end

def update(c)
  users = Collaborator.all.sort_by { rand }

  while user = users.pop
    begin
      s = user.tweet(c,
        settings.oauth_consumer_key,
        settings.oauth_consumer_secret)

      break s
    rescue Twitter::Error::Unauthorized => e
      p e
      user.destroy
    end
  end
end
