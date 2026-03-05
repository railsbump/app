require "rails_helper"

RSpec.describe EmailNotifications::SendAll, type: :service do
  let(:service) { described_class.new }
  let(:gemmy) { FactoryBot.create(:gemmy) }
  let(:email_notification) { EmailNotification.new(email: "test@example.com", notifiable: gemmy) }

  before do
    allow(EmailNotification).to receive(:all).and_return([email_notification])
    allow(ApplicationMailer).to receive(:email_notification).and_return(double(deliver_now: true))
    allow(email_notification).to receive(:delete)
    allow(email_notification.notifiable).to receive_message_chain(:compats, :pending, :none?).and_return(true)
  end

  it "sends email and deletes notification when no pending compats" do
    service.call

    expect(ApplicationMailer).to have_received(:email_notification).with(email_notification)
    expect(email_notification).to have_received(:delete)
  end
end
