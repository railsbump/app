Coverband.configure do |config|
  config.store = Coverband::Adapters::RedisStore.new(
    Redis.new(url: ENV["REDIS_URL"], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
  )
  config.logger = Rails.logger
  config.background_reporting_enabled = true
  config.web_enable_clear = true
  config.ignore = %w[config/boot.rb config/environment.rb config/puma.rb bin/]
  config.password = ENV.fetch("COVERBAND_PASSWORD") if Rails.env.production?
end
