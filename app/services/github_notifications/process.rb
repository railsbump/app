# frozen_string_literal: true

module GithubNotifications
  class Process < Baseline::Service
    def call(github_notification)
      if github_notification.processed?
        raise Error, "GitHub Notification #{github_notification.id} has already been processed."
      end

      if /\A\d+\z/.match?(github_notification.branch)
        @github_notification = github_notification
        do_process
      end

      github_notification.processed!
    end

    private

      def do_process
        compat = Compat.find(@github_notification.branch)

        @github_notification.update! compat: compat

        return unless @github_notification.completed?

        case @github_notification.conclusion
        when "success" then status = :compatible
        when 'failure' then status = :incompatible
        when "skipped", "cancelled"
          if compat.github_notifications.where(conclusion: @github_notification.conclusion)
                                        .where.not(id: @github_notification)
                                        .none?
            compat.unchecked!
            return
          end
          status = :inconclusive
        else raise Error, "Unexpected conclusion: #{@github_notification.conclusion}"
        end

        compat.update! status: status, status_determined_by: "github_check"

        EmailNotifications::SendAll.call_async
      end
  end
end
