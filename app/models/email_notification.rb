class EmailNotification
  include ActiveModel::Model
  include ActiveModel::Validations

  NAMESPACE   = 'email_notifications'
  EMAIL_REGEX = /.+@.+\..+/

  attr_accessor :email, :notifiable

  validates :email, presence: true
  validates :notifiable, presence: true

  validate do
    if email.present? && !EMAIL_REGEX.match?(email)
      errors.add :email, 'is invalid'
    end
  end
  validate do
    if notifiable.present? && !GlobalID::Locator.locate(notifiable)
      errors.add :notifiable, 'is invalid'
    end
  end

  def save
    if valid?
      key = [NAMESPACE, notifiable].join(':')
      Redis.current.sadd key, email
    end
  end
end
