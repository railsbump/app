# This has to be set here instead of `config/application.rb`
# since the environment variable HOST is used,
# which is loaded in the _envkey.rb initializer.
Rails.application.routes.default_url_options =
  Rails.application.config.action_mailer.default_url_options = {
    host:     ENV.fetch('HOST') { 'localhost:3000' },
    protocol: 'https'
  }
