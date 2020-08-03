module GithubNotifications
  class Process < Services::Base
    def call(github_notification)
      if github_notification.processed?
        raise Error, "GitHub Notification #{github_notification.id} has already been processed."
      end

      action     = github_notification.data.fetch('action')
      conclusion = github_notification.data['check_run'].fetch('conclusion')
      branch     = github_notification.data['check_run']['check_suite'].fetch('head_branch')
      compat     = Compat.find(branch)

      github_notification.update! compat: compat

      if action == 'completed'
        unless conclusion.in?(%w(success failure))
          raise Error, "Expected conclusion to be 'success' or 'error', but got: #{conclusion}" \
            rescue Rollbar.error $!, github_notification_id: github_notification.id
        end

        compatible = conclusion == 'success'

        compat.update! compatible: compatible

        EmailNotifications::SendAll.call_async
      end

      github_notification.processed!
    end
  end
end
