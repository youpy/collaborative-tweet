Mongoid.load!('mongoid.yml', ENV['MONGODB_URI'] ? :production : :development)

class Collaborator
  include Mongoid::Document
  include Mongoid::Timestamps

  field :id_str, :type => String
  field :key, :type => String
  field :secret, :type => String
  index({ id_str: 1 }, { unique: true })

  def tweet(c, consumer_key, consumer_secret)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = consumer_key
      config.consumer_secret = consumer_secret
      config.access_token = key
      config.access_token_secret = secret
    end
    client.update c.pad(140)
  end
end
