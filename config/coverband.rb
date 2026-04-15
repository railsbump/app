Coverband.configure do |config|
  config.store = Coverband::Adapters::RedisStore.new(
    Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
  )
  config.logger = Rails.logger
  config.track_views = true
  config.background_reporting_enabled = true
  config.web_enable_clear = true
  config.ignore = %w[config/boot.rb config/environment.rb config/puma.rb bin/]
  config.password = ENV["COVERBAND_PASSWORD"] if ENV["COVERBAND_PASSWORD"].present?
end
