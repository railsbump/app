require "sidekiq"

module Lockfiles
  class StartCheck
    include Sidekiq::Job

    def perform(lockfile_id, rails_release_id = nil)
      lockfile = Lockfile.find(lockfile_id)
      rails_release = rails_release_id ? RailsRelease.find(rails_release_id) : lockfile.next_rails_release
      return unless rails_release

      lockfile_check = LockfileCheck.create_for!(lockfile: lockfile, rails_release: rails_release)
      lockfile.broadcast_checks
      lockfile_check.enqueue_gem_checks
    end
  end
end
