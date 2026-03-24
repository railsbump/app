require "rails_helper"

RSpec.describe GithubNotifications::Process, type: :service do
  let(:service) { described_class.new }
  let(:compat) do
    compat = FactoryBot.create(:compat, status: :pending)
    # Ensure compat has checked_at set so validation passes when updating status
    compat.update_column(:checked_at, Time.current)
    compat
  end
  let(:github_notification) do
    GithubNotification.create!(
      action: "completed",
      branch: compat.id.to_s,
      conclusion: "success"
    )
  end

  describe "#call" do
    context "when notification is not processed" do
      it "processes the notification" do
        service.call(github_notification.id)

        expect(github_notification.reload.processed_at).not_to be_nil
      end

      context "when branch matches a compat id" do
        it "associates the notification with the compat" do
          service.call(github_notification.id)

          expect(github_notification.reload.compat).to eq(compat)
        end

        context "when conclusion is 'success'" do
          it "marks compat as compatible" do
            service.call(github_notification.id)

            expect(compat.reload.status).to eq("compatible")
            expect(compat.status_determined_by).to eq("github_check")
          end
        end

        context "when conclusion is 'failure'" do
          let(:failure_compat) do
            compat = FactoryBot.create(:compat, status: :pending)
            compat.update_column(:checked_at, Time.current)
            compat
          end
          let(:github_notification) do
            GithubNotification.create!(
              action: "completed",
              branch: failure_compat.id.to_s,
              conclusion: "failure"
            )
          end

          it "marks compat as incompatible" do
            service.call(github_notification.id)

            expect(failure_compat.reload.status).to eq("incompatible")
            expect(failure_compat.status_determined_by).to eq("github_check")
          end
        end

        context "when conclusion is 'skipped' and first occurrence" do
          let(:skipped_compat) { FactoryBot.create(:compat, status: :pending) }
          let(:github_notification) do
            GithubNotification.create!(
              action: "completed",
              branch: skipped_compat.id.to_s,
              conclusion: "skipped"
            )
          end

          it "marks compat as unchecked" do
            service.call(github_notification.id)

            expect(skipped_compat.reload.status).to eq("pending")
          end

          it "does not update status_determined_by" do
            service.call(github_notification.id)

            expect(skipped_compat.reload.status_determined_by).to be_nil
          end
        end

        context "when conclusion is 'skipped' and not first occurrence" do
          let(:skipped_compat2) do
            compat = FactoryBot.create(:compat, status: :pending)
            compat.update_column(:checked_at, Time.current)
            compat
          end
          let(:github_notification) do
            GithubNotification.create!(
              action: "completed",
              branch: skipped_compat2.id.to_s,
              conclusion: "skipped"
            )
          end

          before do
            GithubNotification.create!(
              action: "completed",
              branch: skipped_compat2.id.to_s,
              conclusion: "skipped",
              compat: skipped_compat2
            )
          end

          it "marks compat as inconclusive" do
            service.call(github_notification.id)

            expect(skipped_compat2.reload.status).to eq("inconclusive")
            expect(skipped_compat2.status_determined_by).to eq("github_check")
          end
        end

        context "when conclusion is 'cancelled'" do
          let(:cancelled_compat) { FactoryBot.create(:compat, status: :pending) }
          let(:github_notification) do
            GithubNotification.create!(
              action: "completed",
              branch: cancelled_compat.id.to_s,
              conclusion: "cancelled"
            )
          end

          it "marks compat as unchecked if first occurrence" do
            service.call(github_notification.id)

            expect(cancelled_compat.reload.status).to eq("pending")
          end
        end
      end

      context "when branch does not match a compat id" do
        let(:github_notification) do
          GithubNotification.create!(
            action: "completed",
            branch: "not-a-number",
            conclusion: "success"
          )
        end

        it "does not process the compat" do
          service.call(github_notification.id)

          expect(github_notification.reload.processed_at).not_to be_nil
        end
      end
    end

    context "when notification is already processed" do
      before do
        github_notification.processed!
      end

      it "raises an error" do
        expect do
          service.call(github_notification.id)
        end.to raise_error(GithubNotifications::Process::Error, /already been processed/)
      end
    end

    context "when action is not 'completed'" do
      let(:non_completed_compat) { FactoryBot.create(:compat, status: :pending) }
      let(:github_notification) do
        # Create a "completed" notification first so method_missing works correctly
        GithubNotification.create!(action: "completed", branch: "999", conclusion: "success")
        GithubNotification.create!(
          action: "requested",
          branch: non_completed_compat.id.to_s
        )
      end

      it "marks notification as processed" do
        service.call(github_notification.id)

        expect(github_notification.reload.processed_at).not_to be_nil
      end

      it "does not update compat status" do
        original_status = non_completed_compat.status

        service.call(github_notification.id)

        expect(non_completed_compat.reload.status).to eq(original_status)
      end
    end
  end
end
