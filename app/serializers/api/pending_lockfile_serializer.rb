module API
  class PendingLockfileSerializer
    def initialize(lockfile, status_url:, retry_after_seconds:)
      @lockfile = lockfile
      @status_url = status_url
      @retry_after_seconds = retry_after_seconds
    end

    def as_json(*)
      {
        slug: @lockfile.slug,
        status: "pending",
        status_url: @status_url,
        retry_after_seconds: @retry_after_seconds,
        message: message
      }
    end

    private

      def message
        "Compatibility check is running. " \
          "Wait ~#{@retry_after_seconds} seconds, then GET #{@status_url} to retrieve results. " \
          "Re-poll if status is still 'pending'."
      end
  end
end
