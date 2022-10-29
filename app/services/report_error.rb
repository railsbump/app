# frozen_string_literal: true

class ReportError < ::Services::Base
  def call(*error, **params)
    raise *error
  rescue => e
    Sentry.capture_exception e,
      contexts: { data: params }.compact_blank
  end
end
