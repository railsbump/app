module API
  class LockfilesController < BaseController
    PER_GEM_SECONDS = 2
    MIN_POLL_SECONDS = 30
    MAX_POLL_SECONDS = 600

    before_action :set_lockfile, only: :show

    def create
      result = Lockfile::Inspection.call(lockfile_content)

      case result.reason
      when :runnable
        lockfile = result.lockfile
        lockfile.save!
        lockfile.run_check!
        render_pending(lockfile)
      else
        render json: { reason: result.reason, errors: [result.message] }, status: result.http_status
      end
    end

    def show
      render json: LockfileSerializer.new(@lockfile)
    end

    private

      def set_lockfile
        @lockfile = Lockfile.includes(lockfile_checks: [:rails_release, :gem_checks]).find_by(slug: params[:id])
        return if @lockfile

        render json: { errors: ["Lockfile not found"] }, status: :not_found
      end

      def render_pending(lockfile)
        status_url = api_lockfile_url(lockfile)
        retry_after = poll_after_seconds(lockfile)
        response.headers["Location"] = status_url
        response.headers["Retry-After"] = retry_after.to_s

        render json: PendingLockfileSerializer.new(lockfile, status_url: status_url, retry_after_seconds: retry_after),
               status: :accepted
      end

      # Rough per-lockfile estimate: gems / concurrency * average per-gem cost,
      # clamped to a sensible range. Refine once we have production timing data.
      def poll_after_seconds(lockfile)
        concurrency = ENV.fetch("SIDEKIQ_CONCURRENCY", 2).to_i.clamp(1, 25)
        estimate = (lockfile.gems.size * PER_GEM_SECONDS.to_f / concurrency).ceil
        estimate.clamp(MIN_POLL_SECONDS, MAX_POLL_SECONDS)
      end

      def lockfile_content
        params.require(:lockfile).fetch(:content, "").to_s.strip
      end
  end
end
