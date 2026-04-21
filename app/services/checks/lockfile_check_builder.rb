# frozen_string_literal: true

module Checks
  class LockfileCheckBuilder
    def initialize(lockfile, parser)
      @lockfile = lockfile
      @parser = parser
    end

    def call
      return unless @parser.rails_version
      return unless target_release

      @lockfile.lockfile_checks.find_or_create_by!(rails_release: target_release) do |check|
        check.status = "pending"
        check.ruby_version = runtime.ruby_version
        check.rubygems_version = runtime.rubygems_version
        check.bundler_version = runtime.bundler_version
      end
    end

    private

    def target_release
      @target_release ||= RailsRelease.newer_than(@parser.rails_version).first
    end

    def runtime
      @runtime ||= RuntimeResolver.new(
        rails_release: target_release,
        lockfile_ruby: @parser.ruby_version,
        lockfile_bundler: @parser.bundler_version
      ).call
    end
  end
end
