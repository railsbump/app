# This has to be set here instead of `config/environments/production.rb`
# since the environment variable REDIS_URL has to be present,
# which is loaded in the _envkey.rb initializer.
if Rails.env.production?
  Rails.application.config.cache_store = :redis_cache_store, {
    driver:             :hiredis,
    url:                ENV.fetch('REDIS_URL'),
    namespace:          'cache',
    expires_in:         1.month,
    reconnect_attempts: 1,
    error_handler:      -> (method:, returning:, exception:) { Rollbar.warning(exception, method: method, returning: returning) }
  }
end
