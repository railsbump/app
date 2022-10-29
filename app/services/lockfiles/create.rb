# frozen_string_literal: true

require "bundler/lockfile_parser"

module Lockfiles
  class Create < Services::Base
    CONTENT_REGEX = %r(
      GEM
      .+
      DEPENDENCIES
    )xm

    class AlreadyExists < Error
      attr_reader :lockfile

      def initialize(lockfile)
        super nil

        @lockfile = lockfile
      end
    end

    def call(content)
      lockfile = Lockfile.new(content: content)

      if content.present?
        unless CONTENT_REGEX.match?(content)
          raise Error, "This does not look like a valid lockfile."
        end

        parser    = Bundler::LockfileParser.new(content)
        gem_names = parser.dependencies.keys - %w(rails)

        if gem_names.none?
          raise Error, "No gems found in content."
        end

        lockfile.slug = Digest::SHA1.hexdigest(gem_names.join("#"))

        if existing_lockfile = Lockfile.find_by(slug: lockfile.slug)
          raise AlreadyExists.new(existing_lockfile)
        end

        gem_names.each do |gem_name|
          gemmy = Gemmy.find_by(name: gem_name) || Gemmies::Create.call(gem_name)
          lockfile.gemmies << gemmy
        rescue Gemmies::Create::NotFound
          next
        end
      end

      lockfile.tap(&:save!)
    end
  end
end
