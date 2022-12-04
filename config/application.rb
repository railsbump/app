# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module RailsBump
  class Application < Rails::Application
    config.load_defaults 7.0
    config.revision = `git rev-parse --short HEAD 2> /dev/null`.chomp
    config.action_mailer.delivery_method = :postmark
    config.active_record.query_log_tags_enabled = true

    config.middleware.insert 0, Rack::Deflater
    config.middleware.insert 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: %i(get options post patch put)
      end
    end

    Rails.application.routes.default_url_options =
      config.action_mailer.default_url_options = {
        host:     ENV.fetch("HOST"),
        protocol: "https"
      }
  end
end
