# frozen_string_literal: true

module Maintenance
  class CheckSidekiq < ::Services::Base
    MAX_ENQUEUED = 10

    SidekiqError = Class.new(Error)

    def call
      check_uniqueness on_error: :return

      10.tries on: SidekiqError, delay: 1 do
        sidekiq_stats = Sidekiq::Stats.new
        enqueued      = sidekiq_stats.enqueued

        case
        when sidekiq_stats.processes_size.zero?
          raise SidekiqError, 'No Sidekiq processes are running.'
        when enqueued > MAX_ENQUEUED
          raise SidekiqError, "More than #{MAX_ENQUEUED} Sidekiq jobs (#{enqueued}) are enqueued."
        end
      end
    rescue SidekiqError => error
      # Skip Sidekiq when reporting error to Rollbar,
      # since a problem with Sidekiq is what we are reporting.
      Rollbar.with_config use_async: false do
        Rollbar.error error
      end
    end
  end
end
