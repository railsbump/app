module API
  class GithubNotificationsController < BaseController
    def create
      github_notification = GithubNotification.create!(data: request.request_parameters)
      GithubNotifications::Process.call_async github_notification

      head :ok
    end
  end
end
