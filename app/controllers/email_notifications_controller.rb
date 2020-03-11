class EmailNotificationsController < ApplicationController
  def create
    @email_notification = EmailNotification.new(email_notification_params).tap(&:save)
  end

  private

    def email_notification_params
      params.require(:email_notification).permit(:email, :notifiable)
    end
end
