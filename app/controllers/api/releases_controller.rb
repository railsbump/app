module API
  class ReleasesController < BaseController
    def create
      Sentry.capture_message(
        "POST /api/releases hit while temporarily disabled",
        level: :info,
        extra: {
          name: params[:name],
          version: params[:version],
          remote_ip: request.remote_ip,
          user_agent: request.user_agent,
          referer: request.referer
        }
      )

      render json: {
        error: "temporarily_disabled",
        message: "POST /api/releases is temporarily disabled."
      }, status: :service_unavailable
    end
  end
end
