# frozen_string_literal: true

class ApplicationMailerPreview < ActionMailer::Preview
  def email_notification
    unless gemmy = Gemmy.last
      raise "No gemmy found."
    end
    email_notification = EmailNotification.new(
      notifiable: gemmy,
      email:      "dummy@email.com"
    )

    ApplicationMailer.email_notification(email_notification)
  end
end
