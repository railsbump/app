module API
  class LockfilesController < BaseController
    rescue_from ActiveRecord::RecordNotFound do
      render json: { errors: ["Lockfile not found"] }, status: :not_found
    end

    def create
      lockfile = Lockfile.new(content: lockfile_content)

      if lockfile.save
        lockfile.run_check!
        render json: { slug: lockfile.slug }, status: :accepted
      else
        render json: { errors: lockfile.errors.full_messages }, status: :unprocessable_content
      end
    end

    def show
      lockfile = Lockfile.includes(lockfile_checks: [:rails_release, :gem_checks]).find_by!(slug: params[:id])

      render json: lockfile_payload(lockfile)
    end

    private

      def lockfile_content
        params.require(:lockfile).fetch(:content, "").to_s.strip
      end

      def lockfile_payload(lockfile)
        {
          slug: lockfile.slug,
          lockfile_checks: lockfile.lockfile_checks.map { |check| lockfile_check_payload(check) }
        }
      end

      def lockfile_check_payload(check)
        {
          rails_version: check.rails_release.version.to_s,
          status: check.status,
          gem_checks: check.gem_checks.map { |gc| gem_check_payload(gc) }
        }
      end

      def gem_check_payload(gem_check)
        {
          name: gem_check.gem_name,
          locked_version: gem_check.locked_version,
          status: gem_check.status,
          result: gem_check.result,
          earliest_compatible_version: gem_check.earliest_compatible_version,
          error_message: gem_check.error_message
        }
      end
  end
end
