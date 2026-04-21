# frozen_string_literal: true

module Checks
  # Fans out pending gem_checks: resolvable ones get a ResolveGem job,
  # non-resolvable ones are marked complete/skipped in a single update.
  # Jobs are enqueued after the DB update so workers never see stale state.
  class DispatchPendingGemChecks
    def initialize(lockfile_check)
      @lockfile_check = lockfile_check
    end

    def call
      resolvable, skippable = pending.partition(&:resolvable?)

      mark_skipped(skippable)
      enqueue(resolvable)
    end

    private

    def pending
      @lockfile_check.gem_checks.where(status: "pending").to_a
    end

    def mark_skipped(gem_checks)
      return if gem_checks.empty?

      GemCheck.where(id: gem_checks.map(&:id))
        .update_all(status: "complete", result: "skipped", updated_at: Time.current)
    end

    def enqueue(gem_checks)
      gem_checks.each { |gc| Checks::ResolveGem.perform_async(gc.id) }
    end
  end
end
