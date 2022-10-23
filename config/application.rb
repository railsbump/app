# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Railsbump
  class Application < Rails::Application
    config.load_defaults 7.0
    config.revision = `git rev-parse --short HEAD 2> /dev/null`.chomp
    Rails.application.routes.default_url_options =
      config.action_mailer.default_url_options = {
        host:     ENV.fetch("HOST"),
        protocol: ENV.fetch("PROTOCOL")
      }
  end
end
