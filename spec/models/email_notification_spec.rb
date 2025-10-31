require "rails_helper"

RSpec.describe EmailNotification, type: :model do
  let(:gemmy) { FactoryBot.create(:gemmy) }
  let(:email) { "test@example.com" }
  let(:email_notification) { EmailNotification.new(email: email, notifiable: gemmy) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(email_notification).to be_valid
    end

    it "is invalid without an email" do
      email_notification.email = nil
      expect(email_notification).not_to be_valid
      expect(email_notification.errors[:email]).to include("can't be blank")
    end

    it "is invalid with an invalid email format" do
      email_notification.email = "invalid-email"
      expect(email_notification).not_to be_valid
    end

    it "is valid with a valid email format" do
      email_notification.email = "valid@example.com"
      expect(email_notification).to be_valid
    end

    it "is invalid without a notifiable" do
      email_notification.notifiable = nil
      expect(email_notification).not_to be_valid
      expect(email_notification.errors[:notifiable]).to include("can't be blank")
    end
  end

  describe "#notifiable_gid=" do
    it "sets notifiable from global id" do
      gid = gemmy.to_global_id.to_s
      notification = EmailNotification.new(email: email)
      notification.notifiable_gid = gid

      expect(notification.notifiable).to eq(gemmy)
    end
  end

  describe "#save" do
    let(:key) { "email_notifications:#{gemmy.to_global_id}" }

    # Clean up any existing email notifications for this gemmy
    before { Kredis.redis.del(key) if Kredis.redis.exists?(key) }

    it "saves to redis when valid" do
      expect(email_notification.save).to be true
      expect(Kredis.redis.sismember(key, email)).to be true
    end

    it "returns false when invalid" do
      allow(Kredis.redis).to receive(:sadd)
      email_notification.email = nil
      expect(email_notification.save).to be false
      expect(Kredis.redis).not_to have_received(:sadd)
    end
  end

  describe "#delete" do
    it "removes from redis" do
      key = "email_notifications:#{gemmy.to_global_id}"

      # First save the email notification
      email_notification.save
      expect(Kredis.redis.sismember(key, email)).to be true

      # Then delete it
      email_notification.delete

      # Verify it's been removed
      expect(Kredis.redis.sismember(key, email)).to be false
    end
  end

  describe ".all" do
    let(:another_gemmy) { FactoryBot.create(:gemmy, name: "another_gem") }

    before do
      # Clean up all existing email notification keys first
      Kredis.redis.keys("email_notifications:*").each { |key| Kredis.redis.del(key) }

      # Set up test data in redis
      gemmy_key = "email_notifications:#{gemmy.to_global_id}"
      another_key = "email_notifications:#{another_gemmy.to_global_id}"

      # Set up test data
      Kredis.redis.sadd(gemmy_key, email)
      Kredis.redis.sadd(gemmy_key, "another@example.com")
      Kredis.redis.sadd(another_key, "third@example.com")
    end

    after do
      # Clean up
      begin
        Kredis.redis.del("email_notifications:#{gemmy.to_global_id}")
        Kredis.redis.del("email_notifications:#{another_gemmy.to_global_id}")
      rescue
        # Ignore errors during cleanup
      end
    end

    it "returns all email notifications" do
      notifications = EmailNotification.all

      expect(notifications.count).to eq(3)
      expect(notifications.map(&:email)).to contain_exactly(
        email,
        "another@example.com",
        "third@example.com"
      )
      expect(notifications.map(&:notifiable)).to contain_exactly(
        gemmy,
        gemmy,
        another_gemmy
      )
    end
  end
end
