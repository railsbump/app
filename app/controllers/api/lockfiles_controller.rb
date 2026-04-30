module API
  class LockfilesController < BaseController
    def create
      lockfile = Lockfile.new(content: lockfile_content)

      if lockfile.save
        lockfile.run_check!
        render json: { slug: lockfile.slug }, status: :accepted
      else
        render json: { errors: lockfile.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

      def lockfile_content
        params.require(:lockfile).fetch(:content, "").to_s.strip
      end
  end
end
