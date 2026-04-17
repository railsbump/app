# frozen_string_literal: true

module Checks
  # Picks the higher of the lockfile's pinned version and the target Rails
  # release's minimum for Ruby and Bundler; derives RubyGems from Ruby.
  class RuntimeResolver
    Runtime = Data.define(:ruby_version, :rubygems_version, :bundler_version)

    def initialize(rails_release:, lockfile_ruby:, lockfile_bundler:)
      @rails_release = rails_release
      @lockfile_ruby = lockfile_ruby
      @lockfile_bundler = lockfile_bundler
    end

    def call
      ruby_min = min_version(pinned: @rails_release.minimum_ruby_version, requirement: rails_info["ruby_version"])
      bundler_min = min_version(pinned: @rails_release.minimum_bundler_version, requirement: rails_bundler_dependency)
      ruby_version = max_version(@lockfile_ruby, ruby_min)

      Runtime.new(
        ruby_version: ruby_version,
        rubygems_version: RubyRubygemsVersion.for(ruby_version),
        bundler_version: max_version(@lockfile_bundler, bundler_min)
      )
    end

    private

    def min_version(pinned:, requirement:)
      pinned.presence || parse_requirement_min(requirement)
    end

    def rails_info
      @rails_info ||= Gems::V2.info("rails", latest_patch_version)
    end

    def rails_bundler_dependency
      rails_info.dig("dependencies", "runtime")&.find { |d| d["name"] == "bundler" }&.dig("requirements")
    end

    def latest_patch_version
      major_minor = @rails_release.version.to_s

      Gems.versions("rails")
        .select { |v| v["number"].start_with?("#{major_minor}.") && !v["prerelease"] }
        .map { |v| v["number"] }
        .max_by { |v| Gem::Version.new(v) } || "#{major_minor}.0"
    end

    def parse_requirement_min(requirement_string)
      return nil if requirement_string.blank?

      Gem::Requirement.new(requirement_string.split(",").map(&:strip))
        .requirements
        .select { |op, _| op == ">=" }
        .map { |_, v| v.to_s }
        .min_by { |v| Gem::Version.new(v) }
    end

    def max_version(*versions)
      versions.compact.max_by { |v| Gem::Version.new(v) }
    end
  end
end
