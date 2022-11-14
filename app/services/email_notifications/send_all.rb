# frozen_string_literal: true

module EmailNotifications
  class SendAll < Baseline::Service
    def call
      check_uniqueness on_error: :return

      EmailNotification.all.each do |email_notification|
        if email_notification.notifiable.compats.none?(&:pending?)
          ApplicationMailer.email_notification(email_notification).deliver_now
          email_notification.delete
        end
      end
    end
  end
end
