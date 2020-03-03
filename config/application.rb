require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module RailsBump
  class Application < Rails::Application
    config.load_defaults 6.0
    config.current_version = `git rev-parse --short HEAD 2> /dev/null`.chomp
  end
end
