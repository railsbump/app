require "rails_helper"

RSpec.describe GithubNotification, type: :model do
  describe "validations" do
    let(:valid_attributes) do
      {
        action: "completed",
        branch: "main",
        conclusion: "success",
        data: { "test" => "data" }
      }
    end

    it "is valid with valid attributes" do
      notification = GithubNotification.new(valid_attributes)
      expect(notification).to be_valid
    end

    it "is invalid without an action" do
      notification = GithubNotification.new(valid_attributes.except(:action))
      expect(notification).not_to be_valid
      expect(notification.errors[:action]).to include("can't be blank")
    end

    it "is invalid without a branch" do
      notification = GithubNotification.new(valid_attributes.except(:branch))
      expect(notification).not_to be_valid
      expect(notification.errors[:branch]).to include("can't be blank")
    end

    it "validates conclusion when action is 'completed'" do
      notification = GithubNotification.new(
        action: "completed",
        branch: "main",
        conclusion: "invalid_conclusion"
      )
      expect(notification).not_to be_valid
      expect(notification.errors[:conclusion]).to be_present
    end

    it "allows valid conclusions when action is 'completed'" do
      GithubNotification::CONCLUSIONS.each do |conclusion|
        notification = GithubNotification.new(
          action: "completed",
          branch: "main",
          conclusion: conclusion
        )
        expect(notification).to be_valid
      end
    end

    it "does not require conclusion when action is not 'completed'" do
      notification = GithubNotification.new(
        action: "requested",
        branch: "main"
      )
      expect(notification).to be_valid
    end
  end

  describe ".actions" do
    before do
      GithubNotification.create!(action: "completed", branch: "main", conclusion: "success")
      GithubNotification.create!(action: "requested", branch: "main")
      GithubNotification.create!(action: "completed", branch: "main", conclusion: "success")
    end

    it "returns distinct sorted actions" do
      expect(GithubNotification.actions).to eq(["completed", "requested"])
    end
  end

  describe "dynamic predicate methods" do
    before do
      # Create notifications with both "completed" and "requested" actions so they exist in self.class.actions
      GithubNotification.create!(action: "completed", branch: "main", conclusion: "success")
      GithubNotification.create!(action: "requested", branch: "main")
    end

    let(:notification) do
      GithubNotification.create!(
        action: "completed",
        branch: "main",
        conclusion: "success"
      )
    end

    it "responds to action predicate methods" do
      expect(notification.completed?).to be true
      expect(notification.requested?).to be false
    end

    it "delegates to super for non-action methods" do
      expect { notification.nonexistent? }.to raise_error(NoMethodError)
    end
  end

  describe "#processed!" do
    # note: we are using fake data here.
    let(:notification) do
      GithubNotification.create!(
        action: "completed",
        branch: "main",
        conclusion: "success"
      )
    end

    it "sets processed_at timestamp" do
      expect(notification.processed_at).to be_nil

      notification.processed!

      expect(notification.reload.processed_at).not_to be_nil
    end
  end
end
