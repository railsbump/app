module API
  class LockfileSerializer
    def initialize(lockfile)
      @lockfile = lockfile
    end

    def as_json(*)
      {
        slug: @lockfile.slug,
        status: overall_status,
        lockfile_checks: @lockfile.lockfile_checks.map { |c| LockfileCheckSerializer.new(c).as_json }
      }
    end

    private

      def overall_status
        checks = @lockfile.lockfile_checks
        checks.empty? || checks.any?(&:pending?) ? "pending" : "complete"
      end
  end
end
