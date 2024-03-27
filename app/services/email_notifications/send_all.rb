module EmailNotifications
  class SendAll < Baseline::Service
    def call
      check_uniqueness

      EmailNotification.all.each do |email_notification|
        if email_notification.notifiable.compats.pending.none?
          ApplicationMailer.email_notification(email_notification).deliver_now
          email_notification.delete
        end
      end
    end
  end
end
