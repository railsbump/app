module GithubNotifications
  class Process < Services::Base
    def call(github_notification)
      if github_notification.processed?
        raise Error, "GitHub Notification #{github_notification.id} has already been processed."
      end

      compat = Compat.find(github_notification.branch)

      github_notification.update! compat: compat

      if github_notification.completed?
        case github_notification.conclusion
        when 'success' then status = :compatible
        when 'failure' then status = :incompatible
        when 'skipped', 'cancelled'
          if compat.github_notifications.where(conclusion: github_notification.conclusion)
                                        .where.not(id: github_notification)
                                        .none?
            compat.unchecked!
            return
          end

          status = :inconclusive

          Rollbar.error 'Repeated inconclusive Github notification.', \
            github_notification_id: github_notification.id,
            conclusion:             github_notification.conclusion
        else raise Error, "Unexpected conclusion: #{github_notification.conclusion}"
        end

        compat.update! status: status, status_determined_by: 'github_check'

        EmailNotifications::SendAll.call_async
      end

      github_notification.processed!
    end
  end
end
