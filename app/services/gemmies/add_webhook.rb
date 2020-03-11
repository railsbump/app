require 'gems'

module Gemmies
  class AddWebhook < Services::Base
    def call(gemmy)
      if Gems.key.present? && Gems.web_hooks.keys.exclude?(gemmy.name)
        Gems.add_web_hook gemmy.name, api_releases_url
      end
    end
  end
end
