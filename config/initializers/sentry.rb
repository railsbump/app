# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger             = %i(active_support_logger http_logger)
  config.capture_exception_frame_locals = true
  config.release                        = Rails.configuration.revision
  config.send_default_pii               = true
end
