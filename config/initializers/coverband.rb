Coverband.configure do |config|
  config.store = Coverband::Adapters::RedisStore.new(
    Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
  )
  config.track_views = true
  config.background_reporting_enabled = true
end
