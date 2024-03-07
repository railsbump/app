require "sidekiq"

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count)
threads min_threads_count, max_threads_count

if ENV["RAILS_ENV"] == "production"
  require "concurrent-ruby"
  worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count })
  if worker_count > 1
    workers worker_count
  end
end

if ENV.fetch("RAILS_ENV", "development") == "development"
  worker_timeout 3600
end

port        ENV.fetch("PORT",      3000)
environment ENV.fetch("RAILS_ENV", "development")
pidfile     ENV.fetch("PIDFILE",   "tmp/pids/server.pid")

plugin :tmp_restart

preload_app!

sidekiq = nil

on_worker_boot do
  Sidekiq.default_job_options = {
    "retry" => false
  }
  Sidekiq.strict_args!(:warn)
  sidekiq = Sidekiq.configure_embed do |config|
    config.concurrency = 1
    config.redis = {
      url: Baseline::RedisURL.fetch
    }
    config.merge! \
      scheduler: {
        schedule: {
          "Compats::CheckUnchecked" => "*/10 * * * *",
          "Maintenance::Hourly"     => "0    * * * *"
        }.transform_values { { cron: _1 } }
      }
  end.tap(&:run)
end

on_worker_shutdown do
  sidekiq&.stop
end
