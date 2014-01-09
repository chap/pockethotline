if Rails.configuration.x.twilio.account_sid.present? && Rails.configuration.x.twilio.auth_token.present?
  TWILIO = Twilio::REST::Client.new(
    Rails.configuration.x.twilio.account_sid,
    Rails.configuration.x.twilio.auth_token
  ).account
end