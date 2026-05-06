Sentry.init do |config|
  config.breadcrumbs_logger      = %i(active_support_logger http_logger)
  config.max_breadcrumbs         = 20
  config.include_local_variables = false
  config.release                 = Rails.configuration.revision
  config.send_default_pii        = true
  config.traces_sample_rate      = 0.05
  config.profiles_sample_rate    = 0.05
  config.enable_logs             = true
end
