# frozen_string_literal: true

redis_options = {
  url:       Baseline::RedisURL.fetch,
  namespace: "sidekiq"
}

Sidekiq.configure_server do |config|
  config.redis = redis_options
end

Sidekiq.configure_client do |config|
  config.redis = redis_options.merge(size: 1)
end

Sidekiq.default_job_options = {
  "retry" => false
}
