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
      @lockfile_check ||= LockfileCheckBuilder.new(@lockfile, parser).call
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
