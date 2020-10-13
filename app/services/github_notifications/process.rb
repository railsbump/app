module GithubNotifications
  class Process < Services::Base
    def call(github_notification)
      if github_notification.processed?
        raise Error, "GitHub Notification #{github_notification.id} has already been processed."
      end

      compat = Compat.find(github_notification.branch)

      github_notification.update! compat: compat

      if github_notification.completed?
        if github_notification.invalid_conclusion?
          if compat.github_notifications.invalid_conclusion.where.not(id: github_notification).any?
            raise Error, 'Repeated invalid conclusion.'
          end
          compat.unchecked!
          return
        end

        unless github_notification.valid_conclusion?
          raise Error, "Unexpected conclusion: #{github_notification.conclusion}"
        end

        compatible = github_notification.conclusion == 'success'

        compat.update! compatible: compatible, compatible_reason: 'github_check'

        EmailNotifications::SendAll.call_async
      end

      github_notification.processed!
    end
  end
end
