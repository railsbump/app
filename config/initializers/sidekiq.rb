redis_options = {
  url:       ENV.fetch('REDIS_URL'),
  namespace: 'sidekiq'
}

Sidekiq.configure_server do |config|
  config.redis = redis_options
end

Sidekiq.configure_client do |config|
  config.redis = redis_options.merge(size: 1)
end

Sidekiq.default_worker_options = {
  'retry' => false
}
