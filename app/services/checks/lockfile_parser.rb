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

    def platforms
      @parser.platforms.map(&:to_s)
    end
  end
end
