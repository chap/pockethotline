class TwitterIntegration
  def self.tweet_that_operators_are_on_call
    message = Rails.configuration.x.twitter.tweets.sample
    if good_time_to_auto_tweet?(message)
      message.present? && 
      last_twitter_message.created_at < 23.hours.ago && 
      last_twitter_message.body != message
      self.post(message.body)
    end
  end

  def self.good_time_to_auto_tweet?(message)
    User.available_to_take_calls.any?              && 
    message.present?                               && 
    last_twitter_message.created_at < 23.hours.ago && 
    last_twitter_message.body != message
  end

  def self.last_twitter_message
    @last_twitter_message ||= client.user_timeline(Rails.configuration.x.twitter.screen_name).first
  end

  def self.post(message)
    client.update(message)
  end

  def self.active?
    Rails.configuration.x.twitter.consumer_key.present? &&
    Rails.configuration.x.twitter.consumer_secret.present? &&
    Rails.configuration.x.twitter.screen_name.present? &&
    Rails.configuration.x.twitter.access_token.present? &&
    Rails.configuration.x.twitter.access_token_secret.present? &&
    Rails.configuration.x.twitter.tweets.present?
  end

  private
  def self.client
    Twitter.configure do |config|
      config.consumer_key = Rails.configuration.x.twitter.consumer_key
      config.consumer_secret = Rails.configuration.x.twitter.consumer_secret
      config.oauth_token = Rails.configuration.x.twitter.access_token
      config.oauth_token_secret = Rails.configuration.x.twitter.access_token_secret
    end
    Twitter::Client.new
  end
end
