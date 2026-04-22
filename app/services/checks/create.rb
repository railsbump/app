# frozen_string_literal: true

module Checks
  class Create
    def initialize(lockfile)
      @lockfile = lockfile
    end

    def call
      return unless lockfile_check

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

    def parser
      @parser ||= LockfileParser.new(@lockfile.content)
    end

    def lockfile_check
      @lockfile_check ||= build_lockfile_check
    end

    def build_lockfile_check
      return unless parser.rails_version
      return unless target_release

      @lockfile.lockfile_checks.find_or_create_by!(rails_release: target_release) do |check|
        check.status = "pending"
        check.ruby_version = runtime.ruby_version
        check.rubygems_version = runtime.rubygems_version
        check.bundler_version = runtime.bundler_version
      end
    end

    def target_release
      @target_release ||= RailsRelease.newer_than(parser.rails_version).first
    end

    def runtime
      @runtime ||= RuntimeResolver.new(
        rails_release: target_release,
        lockfile_ruby: parser.ruby_version,
        lockfile_bundler: parser.bundler_version
      ).call
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
