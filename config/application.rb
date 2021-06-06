require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module RailsBump
  class Application < Rails::Application
    config.load_defaults 6.0
    config.current_version = `git rev-parse --short HEAD 2> /dev/null`.chomp
    config.action_mailer.preview_path = Rails.root.join('lib', 'mailer_previews')

    require 'cloudflare_proxy'
    config.middleware.use CloudflareProxy
  end
end
