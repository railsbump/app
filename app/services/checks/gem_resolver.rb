# frozen_string_literal: true

module Checks
  # Runs DirectResolver for a single GemCheck, asking for the earliest
  # version of the gem that satisfies the lockfile's Ruby/Bundler/Rails
  # constraints at or above its currently locked version.
  class GemResolver
    def initialize(gem_check)
      @gem_check = gem_check
    end

    def call
      lockfile_check = @gem_check.lockfile_check

      DirectResolver::Subprocess.new(
        rails_version: lockfile_check.rails_release.version.to_s,
        ruby_version: lockfile_check.ruby_version,
        rubygems_version: lockfile_check.rubygems_version,
        bundler_version: lockfile_check.bundler_version,
        dependencies: { @gem_check.gem_name => ">= #{@gem_check.locked_version}" },
        promoter: :earliest
      ).call
    end
  end
end
