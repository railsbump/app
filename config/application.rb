require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module RailsBump
  class Application < Rails::Application
    config.load_defaults 6.0
    config.current_version = `git rev-parse --short HEAD 2> /dev/null`.chomp

    Rails.application.routes.default_url_options =
      config.action_mailer.default_url_options = {
        host:     ENV.fetch('HOST'),
        protocol: 'https'
      }
  end
end
