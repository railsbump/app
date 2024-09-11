module API
  class GithubNotificationsController < BaseController
    def create
      data = request.request_parameters

      github_notification = GithubNotification.create!(
        data:       data,
        action:     data["action"],
        conclusion: data.dig("check_run", "conclusion"),
        branch:     data.dig("check_run", "check_suite", "head_branch")
      )

      GithubNotifications::Process.perform_async github_notification.id

      head :ok
    end
  end
end
