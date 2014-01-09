if Rails.configuration.x.stripe.secret_key.present?
  Stripe.api_key = Rails.configuration.x.stripe.secret_key
end
