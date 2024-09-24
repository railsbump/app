require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine" # Exclude ActionCable
# require "active_storage/engine" # Exclude ActiveStorage
# require "action_mailbox/engine" # Exclude ActionMailbox

Bundler.require(*Rails.groups)

module RailsBump
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib ignore: %w(assets tasks)

    config.time_zone = "Berlin"
    config.revision = ENV.fetch("HEROKU_SLUG_COMMIT") { `git rev-parse HEAD 2> /dev/null`.chomp }
    # config.revision  = begin
    #   ENV.fetch("HATCHBOX_REVISION")
    # rescue KeyError
    #   `git rev-parse HEAD 2> /dev/null`.chomp
    # end.presence or raise "Could not load revision."

    config.active_record.query_log_tags_enabled = true
    config.active_record.sqlite3_production_warning = false

    config.assets.excluded_paths.concat [
      Rails.root.join("app", "assets", "stylesheets")
    ]

    config.i18n.raise_on_missing_translations = true

    config.middleware.insert 0, Rack::Deflater

    Rails.application.routes.default_url_options =
      config.action_mailer.default_url_options = {
        host:     ENV.fetch("HOST"),
        protocol: "https"
      }

    if Rails.version >= "7.2"
      raise "this is not needed anymore, yjit should be enabled by default in rails 7.2."
    end
    # config.after_initialize do
    #   RubyVM::YJIT.enable
    # end
  end
end
