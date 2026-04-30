module API
  class LockfilesController < BaseController
    def create
      lockfile = Lockfile.new(lockfile_params)

      if lockfile.save
        lockfile.run_check!
        render json: { slug: lockfile.slug }, status: :accepted
      else
        render json: { errors: lockfile.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

      def lockfile_params
        permitted = params.require(:lockfile).permit(:content)
        permitted[:content] = permitted[:content].strip if permitted[:content].is_a?(String)
        permitted
      end
  end
end
