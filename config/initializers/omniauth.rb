OmniAuth.config.logger = Rails.logger
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, 'XXXXXXXXX'
  provider :facebook, 'XXXXXXXXX', 'XXXXXXXXX', {:client_options => {site: 'XXXXXXXXX"}}
end
