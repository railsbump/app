module API
  class ResultsController < BaseController
    before_action :authenticate_api_key!

    def create
      @rails_release = RailsRelease.find_by(version: params[:rails_version])
      @compat = @rails_release.compats.find_by_id!(params[:compat_id])

      if @compat.dependencies == params.require(:dependencies).permit!.to_h
        if @compat.process_result(params[:result])
          logger.info "Compat #{@compat.id} processed successfully"
          head :ok
        else
          logger.info "Compat #{@compat.id} process_result failed: #{@compat.errors.full_messages}"
          head :unprocessable_content
        end
      else
        logger.info "Compat #{@compat.id} dependencies do not match"
        head :unprocessable_content
      end
    end

    private

    def authenticate_api_key!
      api_key = request.headers['RAILS-BUMP-API-KEY']

      return head :unauthorized if invalid_api_key?(api_key)

      logger.info "API Key: #{@api_key.name}"
    end

    def invalid_api_key?(api_key)
      return true if api_key.nil?

      @api_key = APIKey.find_by(key: api_key)

      return true if @api_key.nil?
    end
  end
end
