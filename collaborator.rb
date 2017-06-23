Mongoid.load!('mongoid.yml', ENV['MONGODB_URI'] ? :production : :development)

class Collaborator
  include Mongoid::Document
  include Mongoid::Timestamps

  field :id_str, :type => String
  field :key, :type => String
  field :secret, :type => String
  index({ id_str: 1 }, { unique: true })

  def tweet(c, consumer_key, consumer_secret)
    Twitter.configure do |config|
      config.consumer_key = consumer_key
      config.consumer_secret = consumer_secret
      config.oauth_token = key
      config.oauth_token_secret = secret
    end
    twitter = Twitter::Client.new
    twitter.update c.pad(140)
  end
end
