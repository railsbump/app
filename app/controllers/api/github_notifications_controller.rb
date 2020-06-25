module API
  class GithubNotificationsController < BaseController
    def create
      Rollbar.error 'GitHub notification', params: params

      head :ok
    end
  end
end
