Airbrake.configure do |config|
  config.api_key = ENV['ERRBIT_API_KEY']
  config.host    = 'ready4rails4-errbit.herokuapp.com'
  config.port    = 80
  config.secure  = config.port == 443
end
