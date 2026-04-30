module API
  class LockfileCheckSerializer
    def initialize(lockfile_check)
      @lockfile_check = lockfile_check
    end

    def as_json(*)
      {
        target_rails_version: @lockfile_check.rails_release.version.to_s,
        ruby_version: @lockfile_check.ruby_version,
        bundler_version: @lockfile_check.bundler_version,
        rubygems_version: @lockfile_check.rubygems_version,
        status: @lockfile_check.status,
        gem_checks: @lockfile_check.gem_checks.map { |gc| GemCheckSerializer.new(gc).as_json }
      }
    end
  end
end
