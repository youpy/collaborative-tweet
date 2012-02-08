if mongo_uri = ENV['MONGOHQ_URL']
  Mongoid.database = Mongo::Connection.from_uri(mongo_uri).
    db(URI.parse(mongo_uri).path.gsub(/^\//, ''))
else
  host = 'localhost'
  port = Mongo::Connection::DEFAULT_PORT
  Mongoid.database = Mongo::Connection.new(host, port).db('twitter_access_tokens')
end

module Twitter
  class User
    include Mongoid::Document
    include Mongoid::Timestamps

    field :id_str, :type => String
    field :key, :type => String
    field :secret, :type => String
    index :id_str, :unique => true

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
end
