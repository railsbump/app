# frozen_string_literal: true

require "sidekiq"

module Checks
  class ResolveGem
    include Sidekiq::Job

    sidekiq_options retry: 3

    # When all retries are exhausted, the gem itself could not be resolved.
    # Mark just that gem failed (the other gems' results are still valid) and
    # finalize, so the lockfile check leaves "Checking..." once every gem has
    # reached a terminal state.
    sidekiq_retries_exhausted do |job, _exception|
      gem_check = GemCheck.find_by(id: job["args"].first)
      next unless gem_check

      gem_check.failed!
      finalize(gem_check.lockfile_check)
    end

    def perform(gem_check_id)
      gem_check = GemCheck.find(gem_check_id)
      gem_check.perform!

      self.class.finalize(gem_check.lockfile_check)
    end

    def self.finalize(lockfile_check)
      if lockfile_check.pending? && lockfile_check.gem_checks.where(status: "pending").none?
        lockfile_check.update!(status: "complete")
      end

      lockfile_check.lockfile.broadcast_checks
    end
  end
end
