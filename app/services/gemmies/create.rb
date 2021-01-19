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

    class NotFound < Error
      attr_reader :gemmy_name

      def initialize(gemmy_name)
        super nil

        @gemmy_name = gemmy_name
      end

      def message
        "Gem '#{@gemmy_name}' does not exist."
      end
    end

    def call(name)
      if name.blank?
        raise Error, 'Please enter a name.'
      end

      if existing_gemmy = Gemmy.find_by(name: name)
        raise AlreadyExists.new(existing_gemmy)
      end

      begin
        Gems.info name
      rescue Gems::NotFound
        raise NotFound.new(name)
      end

      gemmy = Gemmy.create!(name: name)

      AddWebhook.call_async gemmy
      Process.call_async gemmy

      gemmy
    end
  end
end
