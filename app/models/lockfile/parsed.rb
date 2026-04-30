# frozen_string_literal: true

require "bundler/lockfile_parser"

class Lockfile
  class Parsed
    RUBYGEMS_SOURCES = ["http://rubygems.org/", "https://rubygems.org/"]

    LockedGem = Data.define(:name, :version, :source) do
      def resolvable?
        source.in?(RUBYGEMS_SOURCES) && version.present?
      end
    end

    def initialize(content)
      @parser = Bundler::LockfileParser.new(content)
    end

    # Apps that skip the `rails` umbrella gem (Discourse, some API-only or
    # extracted apps) declare `railties` directly. Either signals a Rails app
    # and both stay in lockstep with the Rails version, so fall back to
    # railties when rails itself is not a top-level spec.
    def rails_version
      spec = parser.specs.find { |s| s.name == "rails" } ||
             parser.specs.find { |s| s.name == "railties" }
      spec&.version&.to_s
    end

    def ruby_version
      parser.ruby_version&.slice(/\d+\.\d+\.\d+/)
    end

    def bundler_version
      parser.bundler_version&.to_s.presence
    end

    def gems
      @gems ||= parser.dependencies.keys.without("rails").map { |name| build_locked_gem(name) }
    end

    private

    attr_reader :parser

    def build_locked_gem(name)
      spec = specs_by_name[name]
      LockedGem.new(name: name, version: spec&.version&.to_s, source: source_value(spec&.source))
    end

    def specs_by_name
      @specs_by_name ||= parser.specs.each_with_object({}) { |s, h| h[s.name] = s }
    end

    def source_value(source)
      case source
      when Bundler::Source::Rubygems then source.remotes.first&.to_s
      when Bundler::Source::Git then source.uri
      when Bundler::Source::Path then source.path.to_s
      end
    end
  end
end
