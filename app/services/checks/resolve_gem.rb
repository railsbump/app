# frozen_string_literal: true

require "sidekiq"

module Checks
  class ResolveGem
    include Sidekiq::Job

    sidekiq_options retry: 3

    # When all retries are exhausted, the gem could not be resolved. Mark the
    # whole lockfile check failed and broadcast, so the page leaves "Checking..."
    # and shows "Failed" instead of hanging on the spinner forever.
    sidekiq_retries_exhausted do |job, _exception|
      gem_check = GemCheck.find_by(id: job["args"].first)
      next unless gem_check

      lockfile_check = gem_check.lockfile_check
      lockfile_check.failed!
      lockfile_check.lockfile.broadcast_checks
    end

    def perform(gem_check_id)
      gem_check = GemCheck.find(gem_check_id)
      gem_check.perform!

      lockfile_check = gem_check.lockfile_check
      mark_lockfile_check_complete(lockfile_check)
      lockfile_check.lockfile.broadcast_checks
    end

    private

    def mark_lockfile_check_complete(lockfile_check)
      return unless lockfile_check.pending?
      return if lockfile_check.gem_checks.where(status: "pending").exists?

      lockfile_check.update!(status: "complete")
    end
  end
end
