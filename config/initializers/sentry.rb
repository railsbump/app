# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger             = %i(active_support_logger http_logger)
  config.capture_exception_frame_locals = true
  config.release                        = Rails.configuration.revision
  config.send_default_pii               = true
  config.traces_sampler = ->(sampling_context) {
    # If this is the continuation of a trace,
    # just use that decision (rate controlled by the caller).
    if parent_sampled = sampling_context[:parent_sampled]
      next parent_sampled
    end

    ENV.fetch("SENTRY_TRACES_SAMPLE_RATE").to_f
  }
end
