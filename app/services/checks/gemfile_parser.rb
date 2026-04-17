# frozen_string_literal: true

require "bundler/lockfile_parser"

module Checks
  class GemfileParser
    def initialize(lockfile)
      @lockfile = lockfile
    end

    def call
      return unless lockfile_rails_version

      target_release = RailsRelease.newer_than(lockfile_rails_version).first
      return unless target_release

      runtime = RuntimeResolver.new(
        rails_release: target_release,
        lockfile_ruby: lockfile_ruby_version,
        lockfile_bundler: parser.bundler_version.presence
      ).call

      @lockfile.lockfile_checks.find_or_create_by!(rails_release: target_release) do |check|
        check.status = "pending"
        check.ruby_version = runtime.ruby_version
        check.rubygems_version = runtime.rubygems_version
        check.bundler_version = runtime.bundler_version
      end
    end

    private

    def parser
      @parser ||= Bundler::LockfileParser.new(@lockfile.content)
    end

    def lockfile_rails_version
      rails_spec = parser.specs.find { |s| s.name == "rails" }
      rails_spec&.version&.segments&.first(2)&.join(".")
    end

    def lockfile_ruby_version
      raw = parser.ruby_version.presence
      return unless raw

      raw[/\d+\.\d+\.\d+/]
    end
  end
end
