class EmailNotificationsController < ApplicationController
  def create
    email_notification = EmailNotification.new(email_notification_params)

    unless email_notification.save
      render partial: "email_notifications/form",
        locals: { email_notification: email_notification },
        status: :unprocessable_entity
    end
  end

  private

    def email_notification_params
      params.require(:email_notification)
            .permit(:email, :notifiable_gid)
    end
end
