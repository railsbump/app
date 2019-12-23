module Gemmies
  class Create < ::Services::Base
    def call(name)
      gemmy = Gemmy.create!(name: name)

      AddWebhook.call_async gemmy

      RailsRelease.find_each do |rails_release|
        RailsCompatibilities::Create.call_async gemmy, rails_release
      end

      gemmy
    end
  end
end
