module API
  class TravisNotificationsController < BaseController
    def create
      # TODO: verify
      # https://docs.travis-ci.com/user/notifications/#verifying-webhook-requests

      travis_notification = TravisNotification.create!(payload: JSON.load(params[:payload]))
      TravisNotifications::Process.call_async travis_notification

      head :ok
    end
  end
end
