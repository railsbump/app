require 'gems'

module Gemmies
  class Create < Services::Base
    class AlreadyExists < Error
      attr_reader :gemmy

      def initialize(gemmy)
        super nil

        @gemmy = gemmy
      end
    end

    def call(name)
      if name.blank?
        raise Error, 'Name is blank.'
      end

      if existing_gemmy = Gemmy.find_by(name: name)
        raise AlreadyExists.new(existing_gemmy)
      end

      begin
        versions = Gems.versions(name).map do |data|
          data.fetch('number')
        end
      rescue Gems::NotFound
        raise Error, 'Name is invalid.'
      end

      gemmy = Gemmy.create!(name: name, versions: versions)

      AddWebhook.call_async gemmy
      Process.call_async gemmy

      gemmy
    end
  end
end
