module GithubNotifications
  class Process < Services::Base
    def call(github_notification)
      if github_notification.processed?
        raise Error, "GitHub Notification #{github_notification.id} has already been processed."
      end

      action, conclusion = github_notification.data.fetch_values('action', 'conclusion')

      next unless action == 'completed'

      unless conclusion.in?(%w(success failure))
        raise Error, "Expected conclusion to be 'success' or 'error', but got: #{conclusion}" rescue Rollbar.error $!, github_notification_id: github_notification.id
      end

      compatible = conclusion == 'success'
      compat     = Compat.find(branch)

      compat.update! compatible: compatible
      github_notification.update! compat: compat

      github_notification.processed!
    end
  end
end
