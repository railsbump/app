module API
  class TravisNotificationsController < BaseController
    def create
      Rollbar.info 'Travis notification', params: params

      # TODO: verify
      # https://docs.travis-ci.com/user/notifications/#verifying-webhook-requests

      # TODO: process
      # https://docs.travis-ci.com/user/notifications/#webhooks-delivery-format

      head :ok
    end
  end
end
