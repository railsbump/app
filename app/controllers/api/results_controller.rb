module API
  class ResultsController < BaseController
    def create
      Sentry.capture_message(
        "POST /api/results hit while temporarily disabled",
        level: :info,
        extra: {
          compat_id:     params[:compat_id],
          rails_version: params[:rails_version],
          strategy:      params.dig(:result, :strategy),
          api_key_name:  request.headers['RAILS-BUMP-API-KEY'].present? ? "<present>" : nil,
          remote_ip:     request.remote_ip,
          user_agent:    request.user_agent,
          referer:       request.referer
        }
      )

      render json: {
        error: "temporarily_disabled",
        message: "POST /api/results is temporarily disabled."
      }, status: :service_unavailable
    end
  end
end
