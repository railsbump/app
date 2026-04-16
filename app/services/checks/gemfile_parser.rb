# frozen_string_literal: true

require "bundler/lockfile_parser"

module Checks
  class GemfileParser
    def initialize(lockfile)
      @lockfile = lockfile
    end

    def call
      current_rails_version = detect_rails_version
      return unless current_rails_version

      target_release = RailsRelease.newer_than(current_rails_version).first
      return unless target_release

      runtime = resolve_runtime_versions(target_release)

      @lockfile.lockfile_checks.find_or_create_by!(rails_release: target_release) do |check|
        check.status = "pending"
        check.ruby_version = runtime[:ruby_version]
        check.rubygems_version = runtime[:rubygems_version]
        check.bundler_version = runtime[:bundler_version]
      end
    end

    private

    def parser
      @parser ||= Bundler::LockfileParser.new(@lockfile.content)
    end

    def detect_rails_version
      rails_spec = parser.specs.find { |s| s.name == "rails" }
      rails_spec&.version&.segments&.first(2)&.join(".")
    end

    def resolve_runtime_versions(target_release)
      target_patch = find_latest_patch_version(target_release)
      rails_info = Gems::V2.info("rails", target_patch)

      bundler_dep = rails_info.dig("dependencies", "runtime")&.find { |d| d["name"] == "bundler" }

      ruby_min = release_or_api_min(target_release.minimum_ruby_version, rails_info["ruby_version"])
      bundler_min = release_or_api_min(target_release.minimum_bundler_version, bundler_dep&.dig("requirements"))

      lockfile_ruby = parse_lockfile_ruby_version
      lockfile_bundler = parser.bundler_version.presence

      ruby_version = max_version(lockfile_ruby, ruby_min)

      {
        ruby_version: ruby_version,
        rubygems_version: RubyRubygemsVersion.for(ruby_version),
        bundler_version: max_version(lockfile_bundler, bundler_min)
      }
    end

    def find_latest_patch_version(target_release)
      major_minor = target_release.version.to_s

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

    def parse_lockfile_ruby_version
      raw = parser.ruby_version.presence
      return unless raw

      raw[/\d+\.\d+\.\d+/]
    end

    def max_version(*versions)
      versions.compact.max_by { |v| Gem::Version.new(v) }
    end
  end
end
