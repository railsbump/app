ActionMailer::Base.smtp_settings = {
  port:           ENV['MAIL_PORT'],
  address:        ENV['MAIL_ADDRESS'],
  user_name:      ENV['MAIL_USER_NAME'],
  password:       ENV['MAIL_PASSWORD'],
  domain:         ENV['MAIL_DOMAIN'],
  authentication: ENV['MAIL_AUTHENTICATION']
}
ActionMailer::Base.delivery_method = :smtp
