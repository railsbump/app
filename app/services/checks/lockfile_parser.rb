# frozen_string_literal: true

require "bundler/lockfile_parser"

module Checks
  class LockfileParser
    def initialize(content)
      @parser = Bundler::LockfileParser.new(content)
    end

    def specs
      @parser.specs
    end

    def dependencies
      @parser.dependencies
    end

    def rails_version
      rails_spec = @parser.specs.find { |s| s.name == "rails" }
      rails_spec&.version&.segments&.first(2)&.join(".")
    end

    def ruby_version
      raw = @parser.ruby_version.presence
      return unless raw

      raw[/\d+\.\d+\.\d+/]
    end

    def bundler_version
      @parser.bundler_version.presence
    end

    def spec_for(gem_name)
      specs_by_name[gem_name]
    end

    def source_for(gem_name)
      spec = spec_for(gem_name)
      return unless spec

      case spec.source
      when Bundler::Source::Rubygems then spec.source.remotes.first&.to_s
      when Bundler::Source::Git      then spec.source.uri
      when Bundler::Source::Path     then spec.source.path.to_s
      end
    end

    private

    def specs_by_name
      @specs_by_name ||= @parser.specs.each_with_object({}) { |s, h| h[s.name] = s }
    end
  end
end
