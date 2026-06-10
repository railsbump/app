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
      broadcast_gem_check(gem_check)
      finalize(gem_check.lockfile_check)
    end

    def perform(gem_check_id)
      gem_check = GemCheck.find(gem_check_id)
      gem_check.perform!

      self.class.broadcast_gem_check(gem_check)
      self.class.finalize(gem_check.lockfile_check)
    end

    def self.broadcast_gem_check(gem_check)
      Turbo::StreamsChannel.broadcast_replace_to(
        gem_check.lockfile_check.lockfile, :gem_checks,
        target: ActionView::RecordIdentifier.dom_id(gem_check),
        partial: "gem_checks/gem_check",
        locals: { gem_check: gem_check }
      )
    end

    def self.finalize(lockfile_check)
      return unless lockfile_check.pending?
      return if lockfile_check.gem_checks.where(status: "pending").exists?

      lockfile_check.update!(status: "complete")

      Turbo::StreamsChannel.broadcast_replace_to(
        lockfile_check.lockfile, :gem_checks,
        target: ActionView::RecordIdentifier.dom_id(lockfile_check, :status),
        partial: "lockfile_checks/status_badge",
        locals: { lockfile_check: lockfile_check }
      )
    end
  end
end
