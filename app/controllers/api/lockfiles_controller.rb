module API
  class LockfilesController < BaseController
    POLL_AFTER_SECONDS = 60

    rescue_from ActiveRecord::RecordNotFound do
      render json: { errors: ["Lockfile not found"] }, status: :not_found
    end

    def create
      lockfile = Lockfile.new(content: lockfile_content)

      if lockfile.save
        lockfile.run_check!
        render_accepted(lockfile)
      else
        render json: { errors: lockfile.errors.full_messages }, status: :unprocessable_content
      end
    end

    def show
      lockfile = Lockfile.includes(lockfile_checks: [:rails_release, :gem_checks]).find_by!(slug: params[:id])

      render json: LockfileSerializer.new(lockfile)
    end

    private

      def render_accepted(lockfile)
        status_url = api_lockfile_url(lockfile, host: request.host_with_port)
        response.headers["Location"] = status_url
        response.headers["Retry-After"] = POLL_AFTER_SECONDS.to_s

        render json: AcceptedLockfileSerializer.new(lockfile, status_url: status_url, retry_after_seconds: POLL_AFTER_SECONDS),
               status: :accepted
      end

      def lockfile_content
        params.require(:lockfile).fetch(:content, "").to_s.strip
      end
  end
end
