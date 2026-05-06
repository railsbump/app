module API
  class GithubNotificationsController < BaseController
    def create
      Sentry.capture_message(
        "POST /api/github_notifications hit while temporarily disabled",
        level: :info,
        extra: {
          action:     request.request_parameters["action"],
          conclusion: request.request_parameters.dig("check_run", "conclusion"),
          branch:     request.request_parameters.dig("check_run", "check_suite", "head_branch"),
          remote_ip:  request.remote_ip,
          user_agent: request.user_agent,
          referer:    request.referer
        }
      )

      render json: {
        error: "temporarily_disabled",
        message: "POST /api/github_notifications is temporarily disabled."
      }, status: :service_unavailable
    end
  end
end
