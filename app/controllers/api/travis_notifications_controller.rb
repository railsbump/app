module API
  class TravisNotificationsController < BaseController
    def create
      travis_notification = TravisNotification.create!(data: JSON.load(params[:payload]))
      TravisNotifications::Process.call_async travis_notification

      head :ok
    end
  end
end
