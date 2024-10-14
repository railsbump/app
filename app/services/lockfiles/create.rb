require "bundler/lockfile_parser"

module Lockfiles
  class Create < Baseline::Service
    class AlreadyExists < Error
      attr_reader :lockfile

      def initialize(lockfile)
        super nil

        @lockfile = lockfile
      end
    end

    def call(content)
      lockfile = build(content)

      lockfile.tap(&:save)
    end

    def build(content)
      result = Lockfile.new(content: content)

      if result.valid?
        if existing_lockfile = Lockfile.find_by(slug: result.slug)
          raise AlreadyExists.new(existing_lockfile)
        end

        result
      else
        result
      end
    end
  end
end
