# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module RailsBump
  class Application < Rails::Application
    config.load_defaults 7.0
    config.revision = begin
      ENV.fetch("REVISION")
    rescue KeyError
      `git rev-parse HEAD 2> /dev/null`.chomp
    end.presence or raise "Could not load revision."

    config.action_mailer.delivery_method = :postmark
    config.active_record.query_log_tags_enabled = true

    config.middleware.insert 0, Rack::Deflater
    config.middleware.insert 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: %i(get options post patch put)
      end
    end

    config.to_prepare do
      Rails.logger.info "to_prepare! asset_host: #{Rails.application.config.asset_host}"
      if asset_host = Rails.application.config.asset_host
        {
          "packs/manifest.json"  => nil,
          "assets/manifest.json" => "assets/.sprockets-manifest-#{Digest::MD5.hexdigest Rails.application.config.revision}.json"
        }.each do |remote_path, local_path|
          content = HTTP.get("#{asset_host}/#{remote_path}").body
          File.write "public/#{local_path || remote_path}", content
        end
      end
    end

    Rails.application.routes.default_url_options =
      config.action_mailer.default_url_options = {
        host:     ENV.fetch("HOST"),
        protocol: "https"
      }
  end
end
