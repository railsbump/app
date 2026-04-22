# frozen_string_literal: true

require "bundler/lockfile_parser"

class Lockfile
  class Parsed
    RUBYGEMS_SOURCE = "https://rubygems.org/"

    LockedGem = Struct.new(:name, :version, :source, keyword_init: true) do
       def resolvable?
         source == RUBYGEMS_SOURCE && version.present?
       end
     end

    def initialize(content)
      @parser = Bundler::LockfileParser.new(content)
    end

    def rails_version
      return unless rails_spec

      "#{rails_spec.version.segments[0]}.#{rails_spec.version.segments[1]}"
    end

    def ruby_version
      raw = @parser.ruby_version.presence
      return unless raw

      raw[/\d+\.\d+\.\d+/]
    end

    def bundler_version
      @parser.bundler_version&.to_s.presence
    end

    def gems
      @gems ||= top_level_gem_names.map { |name| build_locked_gem(name) }
    end

    private

    def top_level_gem_names
      @parser.dependencies.keys - %w[rails]
    end

    def rails_spec
      @rails_spec ||= @parser.specs.find { |s| s.name == "rails" }
    end

    def specs_by_name
      @specs_by_name ||= @parser.specs.each_with_object({}) { |s, h| h[s.name] = s }
    end

    def build_locked_gem(name)
      spec = specs_by_name[name]
      LockedGem.new(name: name, version: spec&.version&.to_s, source: source_for(spec))
    end

    def source_for(spec)
      return unless spec

      case spec.source
      when Bundler::Source::Rubygems then spec.source.remotes.first&.to_s
      when Bundler::Source::Git then spec.source.uri
      when Bundler::Source::Path then spec.source.path.to_s
      end
    end
  end
end
