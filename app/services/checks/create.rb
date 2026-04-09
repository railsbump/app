# frozen_string_literal: true

require "bundler/lockfile_parser"

module Checks
  class Create
    def initialize(lockfile)
      @lockfile = lockfile
    end

    def call
      parser = Bundler::LockfileParser.new(@lockfile.content)
      current_rails_version = detect_rails_version(parser)
      return unless current_rails_version

      target_release = find_next_rails_release(current_rails_version)
      return unless target_release

      runtime = resolve_runtime_versions(parser, target_release)

      lockfile_check = @lockfile.lockfile_checks.find_or_create_by!(rails_release: target_release) do |check|
        check.status = "pending"
        check.ruby_version = runtime[:ruby_version]
        check.rubygems_version = runtime[:rubygems_version]
        check.bundler_version = runtime[:bundler_version]
      end

      specs_by_name = parser.specs.each_with_object({}) { |spec, h| h[spec.name] = spec }
      gem_names = parser.dependencies.keys - %w[rails]

      gem_names.each do |gem_name|
        spec = specs_by_name[gem_name]

        lockfile_check.gem_checks.find_or_create_by!(gem_name: gem_name) do |gc|
          gc.locked_version = spec&.version&.to_s
          gc.source = extract_source(spec)
        end
      end

      lockfile_check.gem_checks.where(status: "pending").find_each do |gem_check|
        if gem_check.resolvable?
          Checks::ResolveGem.perform_async(gem_check.id)
        else
          gem_check.update!(status: "complete", result: "skipped")
        end
      end

      lockfile_check
    end

    private

    def detect_rails_version(parser)
      rails_spec = parser.specs.find { |s| s.name == "rails" }
      return unless rails_spec

      version = rails_spec.version
      "#{version.segments[0]}.#{version.segments[1]}"
    end

    def find_next_rails_release(current_version)
      current = Gem::Version.new(current_version)

      RailsRelease
        .order(:version)
        .select { |r| Gem::Version.new(r.version) > current }
        .first
    end

    def resolve_runtime_versions(parser, target_release)
      target_patch = find_latest_patch_version(target_release)
      rails_info = Gems::V2.info("rails", target_patch)

      bundler_dep = rails_info.dig("dependencies", "runtime")&.find { |d| d["name"] == "bundler" }

      ruby_min = target_release.minimum_ruby_version.presence ||
        extract_minimum_version(rails_info["ruby_version"])
      bundler_min = target_release.minimum_bundler_version.presence ||
        extract_minimum_version(bundler_dep&.dig("requirements"))

      lockfile_ruby = parse_lockfile_ruby_version(parser)
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

    def extract_minimum_version(requirement_string)
      return nil if requirement_string.blank?

      Gem::Requirement.new(requirement_string.split(",").map(&:strip))
        .requirements
        .select { |op, _| op == ">=" }
        .map { |_, v| v.to_s }
        .min_by { |v| Gem::Version.new(v) }
    end

    def parse_lockfile_ruby_version(parser)
      raw = parser.ruby_version.presence
      return unless raw

      raw[/\d+\.\d+\.\d+/]
    end

    def max_version(a, b)
      return a if b.nil?
      return b if a.nil?

      [Gem::Version.new(a), Gem::Version.new(b)].max.to_s
    end

    def extract_source(spec)
      return unless spec

      source = spec.source
      case source
      when Bundler::Source::Rubygems
        source.remotes.first&.to_s
      when Bundler::Source::Git
        source.uri
      when Bundler::Source::Path
        source.path.to_s
      end
    end
  end
end
