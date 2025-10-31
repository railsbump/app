require "rails_helper"

RSpec.describe API::GithubNotificationsController, type: :controller do
  describe "POST #create" do
    # Realistic GitHub Check Run webhook payload structure
    let(:notification_data) do
      {
        "action" => "completed",
        "check_run" => {
          "id" => 1234567890,
          "conclusion" => "success",
          "check_suite" => {
            "head_branch" => "123",
          },
        },
      }
    end

    before { allow(GithubNotifications::Process).to receive(:perform_async) }

    it "creates a GithubNotification" do
      expect do
        post :create, params: notification_data
      end.to change(GithubNotification, :count).by(1)
    end

    it "schedules processing of the notification" do
      post :create, params: notification_data

      notification = GithubNotification.last
      expect(GithubNotifications::Process).to have_received(:perform_async).with(notification.id)
    end

    it "returns 200 OK" do
      post :create, params: notification_data
      expect(response).to have_http_status(:ok)
    end

    it "sets the correct attributes on the notification" do
      post :create, params: notification_data

      notification = GithubNotification.last
      expect(notification.action).to eq("completed")
      expect(notification.conclusion).to eq("success")
      expect(notification.branch).to eq("123")

      # Verify key parts of the stored data (Rails JSON column may stringify some values)
      expect(notification.data["action"]).to eq("completed")
      expect(notification.data.dig("check_run", "conclusion")).to eq("success")
      expect(notification.data.dig("check_run", "check_suite", "head_branch")).to eq("123")
      expect(notification.data.dig("check_run", "id")).to eq("1234567890")
    end
  end
end
