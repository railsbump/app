module Maintenance
  class Hourly < Baseline::Service
    def call
      check_uniqueness

      call_all_private_methods_without_args \
        raise_errors: false

      [
        CheckGitBranches,
        EmailNotifications::SendAll
      ].each_with_index do |service, index|
        service.call_in (index + 1).minutes
      end
    end

    private

      def delete_old_github_notifications
        GithubNotification.created_before(1.month.ago).destroy_all
      end

      def check_pending_compats
        pending_compats = Compat
          .pending
          .checked_before(2.hours.ago)

        if pending_compats.any?
          ReportError.call "Some compats have been pending for a long time.",
            count: pending_compats.size
        end
      end

      def regenerate_sitemap
        SitemapGenerator.verbose = false
        SitemapGenerator::Interpreter.run
      end
  end
end
