module API
  class ResultsController < BaseController
    before_action :authenticate_api_key!

    def create
      Sentry.capture_message(
        "POST /api/results hit while temporarily disabled",
        level: :info,
        extra: {
          compat_id:     params[:compat_id],
          rails_version: params[:rails_version],
          strategy:      params.dig(:result, :strategy),
          api_key_name:  @api_key&.name,
          remote_ip:     request.remote_ip,
          user_agent:    request.user_agent,
          referer:       request.referer
        }
      )

      render json: {
        error: "temporarily_disabled",
        message: "POST /api/results is temporarily disabled while we investigate a memory issue."
      }, status: :service_unavailable
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
