# frozen_string_literal: true

require "sidekiq"

module Checks
  class ResolveGem
    include Sidekiq::Job

    def perform(gem_check_id)
      gem_check = GemCheck.find(gem_check_id)
      gem_check.perform!

      lockfile_check = gem_check.lockfile_check
      mark_lockfile_check_complete(lockfile_check)
      lockfile_check.lockfile.broadcast_checks
    end

    private

    def mark_lockfile_check_complete(lockfile_check)
      return if lockfile_check.gem_checks.where(status: "pending").exists?

      lockfile_check.update!(status: "complete")
    end
  end
end
