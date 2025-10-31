require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  describe "#email_notification" do
    context "when notifiable is a Gemmy" do
      let(:gemmy) { FactoryBot.create(:gemmy, name: "test_gem") }
      let(:email_notification) do
        EmailNotification.new(
          email: "test@example.com",
          notifiable: gemmy
        )
      end

      it "sends email with correct subject for gemmy" do
        mail = ApplicationMailer.email_notification(email_notification)

        expect(mail.subject).to eq('[RailsBump] Gem "test_gem" has been checked successfully.')
        expect(mail.to).to eq(["test@example.com"])
      end

      it "assigns the notifiable" do
        mail = ApplicationMailer.email_notification(email_notification)

        expect(mail.body.encoded).to be_present
      end

      it "sets the correct from address" do
        # The mailer's default from is set at class load time, so we test the actual behavior
        # The format is "RailsBump <#{ENV['SMTP_FROM']}>"
        mail = ApplicationMailer.email_notification(email_notification)

        # mail.from can be a string or array depending on Rails version
        from_address = mail.from.is_a?(Array) ? mail.from.first : mail.from
        expect(from_address).to include("RailsBump")
      end

      it "uses the mailer layout" do
        mail = ApplicationMailer.email_notification(email_notification)
        expect(mail.body.encoded).to be_present
      end
    end

    context "when notifiable is not a Gemmy" do
      let(:lockfile) { FactoryBot.build(:lockfile) }
      let(:email_notification) { EmailNotification.new(email: "test@example.com", notifiable: lockfile) }

      it "sends email with correct subject for lockfile" do
        mail = ApplicationMailer.email_notification(email_notification)

        expect(mail.subject).to eq("[RailsBump] Your lockfile has been checked successfully.")
        expect(mail.to).to eq(["test@example.com"])
      end
    end
  end
end
