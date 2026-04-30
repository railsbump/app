module API
  class LockfileCheckSerializer
    def initialize(lockfile_check)
      @lockfile_check = lockfile_check
    end

    def as_json(*)
      {
        rails_version: @lockfile_check.rails_release.version.to_s,
        status: @lockfile_check.status,
        gem_checks: @lockfile_check.gem_checks.map { |gc| GemCheckSerializer.new(gc).as_json }
      }
    end
  end
end
