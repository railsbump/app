module Maintenance
  class CheckUnprocessedGithubNotifications < Services::Base
    def call
      check_uniqueness on_error: :return

      unprocessed_github_notifications = GithubNotification.unprocessed
                                                           .created_after(1.hour.ago)

      if unprocessed_github_notifications.any?
        raise Error, 'Some Github notifications are still unprocessed.' \
          rescue Rollbar.error $!, count: unprocessed_github_notifications.size
      end
    end
  end
end
