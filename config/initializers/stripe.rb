Rails.configuration.stripe = {
  :publishable_key => 'XXXXXXXXX',
  :secret_key      => 'XXXXXXXXX'
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
