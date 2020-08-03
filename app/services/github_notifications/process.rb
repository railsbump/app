module GithubNotifications
  class Process < Services::Base
    def call(github_notification)
      if github_notification.processed?
        raise Error, "GitHub Notification #{github_notification.id} has already been processed."
      end

      action     = github_notification.data.fetch('action')
      conclusion = github_notification.data['check_run'].fetch('conclusion')
      branch     = github_notification.data['check_run']['check_suite'].fetch('head_branch')

      if action == 'completed'
        unless conclusion.in?(%w(success failure))
          raise Error, "Expected conclusion to be 'success' or 'error', but got: #{conclusion}" \
            rescue Rollbar.error $!, github_notification_id: github_notification.id
        end

        compatible = conclusion == 'success'
        compat     = Compat.find(branch)

        compat.update! compatible: compatible
        github_notification.update! compat: compat
      end

      github_notification.processed!
    end
  end
end
