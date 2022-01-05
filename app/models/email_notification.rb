class EmailNotification
  include ActiveModel::Model

  NAMESPACE       = "email_notifications"
  NAMESPACE_REGEX = /\A#{Regexp.escape NAMESPACE}:(.+)/
  EMAIL_REGEX     = /.+@.+\..+/

  attr_accessor :email, :notifiable

  validates :email, presence: true
  validates :notifiable, presence: true

  validate do
    if email.present? && !EMAIL_REGEX.match?(email)
      errors.add :email, "is invalid"
    end
  end

  def self.all
    Redis.current.keys("#{NAMESPACE}:*").flat_map do |key|
      unless notifiable = GlobalID::Locator.locate(key[NAMESPACE_REGEX, 1])
        raise "Could not find notifiable: #{key}"
      end

      Redis.current.smembers(key).map do |email|
        new notifiable: notifiable, email: email
      end
    end
  end

  def notifiable_gid=(value)
    self.notifiable = GlobalID::Locator.locate(value)
  end

  def save
    unless valid?
      raise "Email notification is invalid: #{errors.full_messages.join(", ")}"
    end

    Redis.current.sadd key, email
  end

  def delete
    Redis.current.srem key, email
  end

  private

    def key
      [NAMESPACE, notifiable.to_global_id].join(":")
    end
end
