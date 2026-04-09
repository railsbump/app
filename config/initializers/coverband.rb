Coverband.configure do |config|
  config.store = Coverband::Adapters::RedisStore.new($redis)
  config.track_views = true
  config.background_reporting_enabled = true
end
