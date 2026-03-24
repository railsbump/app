require "rails_helper"

RSpec.describe Maintenance::Hourly, type: :service do
  let(:service) { described_class.new }

  describe "#call" do
    before do
      allow(CheckGitBranches).to receive(:call_in)
      allow(EmailNotifications::SendAll).to receive(:call_in)
      allow(SitemapGenerator).to receive(:verbose=)
      allow(SitemapGenerator::Interpreter).to receive(:run)
    end

    it "schedules CheckGitBranches" do
      service.call

      expect(CheckGitBranches).to have_received(:call_in).with(1.minute)
    end

    it "schedules EmailNotifications::SendAll" do
      service.call

      expect(EmailNotifications::SendAll).to have_received(:call_in).with(2.minutes)
    end

    describe "private methods" do
      describe "#delete_old_github_notifications" do
        let!(:old_notification) do
          GithubNotification.create!(
            action: "completed",
            branch: "main",
            conclusion: "success"
          )
        end

        let!(:recent_notification) do
          GithubNotification.create!(
            action: "completed",
            branch: "main",
            conclusion: "success"
          )
        end

        before do
          old_notification.update_column(:created_at, 2.months.ago)
          allow(GithubNotification).to receive(:created_before).and_return(GithubNotification.where(id: old_notification.id))
        end

        it "deletes notifications older than 1 month" do
          service.call

          expect(GithubNotification.exists?(old_notification.id)).to be false
          expect(GithubNotification.exists?(recent_notification.id)).to be true
        end
      end

      describe "#check_pending_compats" do
        before do
          allow(ReportError).to receive(:call)
          allow(Compat).to receive_message_chain(:pending, :checked_before).and_return(double(any?: false))
        end

        it "does not report error when no pending compats" do
          service.call

          expect(ReportError).not_to have_received(:call)
        end

        context "when there are old pending compats" do
          let(:pending_compats) { double(size: 5) }

          before do
            allow(Compat).to receive_message_chain(:pending, :checked_before).and_return(pending_compats)
            allow(pending_compats).to receive(:any?).and_return(true)
          end

          it "reports an error" do
            service.call

            expect(ReportError).to have_received(:call).with(
              "Some compats have been pending for a long time.",
              count: 5
            )
          end
        end
      end

      describe "#regenerate_sitemap" do
        it "regenerates the sitemap" do
          service.call

          expect(SitemapGenerator).to have_received(:verbose=).with(false)
          expect(SitemapGenerator::Interpreter).to have_received(:run)
        end
      end
    end
  end
end
