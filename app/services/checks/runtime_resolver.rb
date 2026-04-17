# frozen_string_literal: true

module Checks
  class RuntimeResolver
    Runtime = Data.define(:ruby_version, :rubygems_version, :bundler_version)

    def initialize(target_release, lockfile_ruby:, lockfile_bundler:)
      @target_release = target_release
      @lockfile_ruby = lockfile_ruby
      @lockfile_bundler = lockfile_bundler
    end

    def call
      ruby_min = release_or_api_min(@target_release.minimum_ruby_version, rails_info["ruby_version"])
      bundler_min = release_or_api_min(@target_release.minimum_bundler_version, bundler_requirement)

      ruby_version = max_version(@lockfile_ruby, ruby_min)

      Runtime.new(
        ruby_version: ruby_version,
        rubygems_version: RubyRubygemsVersion.for(ruby_version),
        bundler_version: max_version(@lockfile_bundler, bundler_min)
      )
    end

    private

    def rails_info
      @rails_info ||= Gems::V2.info("rails", latest_patch_version)
    end

    def bundler_requirement
      rails_info.dig("dependencies", "runtime")&.find { |d| d["name"] == "bundler" }&.dig("requirements")
    end

    def latest_patch_version
      major_minor = @target_release.version.to_s

      Gems.versions("rails")
        .select { |v| v["number"].start_with?("#{major_minor}.") && !v["prerelease"] }
        .map { |v| v["number"] }
        .max_by { |v| Gem::Version.new(v) } || "#{major_minor}.0"
    end

    def release_or_api_min(release_value, api_requirement)
      release_value.presence || extract_minimum_version(api_requirement)
    end

    def extract_minimum_version(requirement_string)
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
