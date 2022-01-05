require "gems"

module Gemmies
  class AddWebhook < Services::Base
    IGNORED_ERROR_MESSAGE = /has already been registered/

    def call(gemmy)
      return unless Gems.key.present?

      begin
        Gems.add_web_hook gemmy.name, api_releases_url
      rescue Gems::GemError => error
        unless IGNORED_ERROR_MESSAGE.match?(error.message)
          raise error
        end
      end
    end
  end
end
