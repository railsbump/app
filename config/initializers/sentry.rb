Sentry.init do |config|
  config.breadcrumbs_logger      = %i(active_support_logger http_logger)
  config.include_local_variables = true
  config.release                 = Rails.configuration.revision
  config.send_default_pii        = true
  config.traces_sample_rate      = 0.05
  config.profiles_sample_rate    = 0.05
end
