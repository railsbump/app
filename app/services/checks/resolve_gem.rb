# frozen_string_literal: true

require "sidekiq"

module Checks
  class ResolveGem
    include Sidekiq::Job

    def perform(gem_check_id)
      gem_check = GemCheck.find(gem_check_id)
      result = Checks::GemResolver.new(gem_check).call

      if result.compatible?
        resolved_version = result.resolved_version(gem_check.gem_name)

        if resolved_version && Gem::Version.new(resolved_version) > Gem::Version.new(gem_check.locked_version)
          gem_check.update!(status: "complete", result: "upgrade_needed", earliest_compatible_version: resolved_version)
        else
          gem_check.update!(status: "complete", result: "compatible")
        end
      else
        gem_check.update!(status: "complete", result: "incompatible", error_message: result.error&.truncate(1000))
      end

      broadcast_gem_check(gem_check)
      mark_lockfile_check_complete(gem_check.lockfile_check)
    end

    private

    def broadcast_gem_check(gem_check)
      lockfile = gem_check.lockfile_check.lockfile

      Turbo::StreamsChannel.broadcast_replace_to(
        lockfile, :gem_checks,
        target: ActionView::RecordIdentifier.dom_id(gem_check),
        partial: "gem_checks/gem_check",
        locals: { gem_check: gem_check }
      )
    end

    def mark_lockfile_check_complete(lockfile_check)
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
