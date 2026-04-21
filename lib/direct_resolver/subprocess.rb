# frozen_string_literal: true

require "open3"
require "json"

class DirectResolver
  class Subprocess
    SCRIPT = File.expand_path("../../../bin/resolve_gem", __FILE__)
    MUTEX = Mutex.new

    def initialize(rails_version:, ruby_version:, dependencies: {}, rubygems_version: Gem::VERSION, bundler_version: Bundler::VERSION, promoter: :latest)
      @config = {
        rails_version: rails_version,
        ruby_version: ruby_version,
        rubygems_version: rubygems_version,
        bundler_version: bundler_version,
        dependencies: dependencies,
        promoter: promoter.to_s
      }
    end

    def call
      stdout, stderr, status = MUTEX.synchronize do
        Open3.capture3(
          { "BUNDLE_GEMFILE" => "" },
          RbConfig.ruby, SCRIPT,
          stdin_data: JSON.generate(@config)
        )
      end

      unless status.success?
        return DirectResolver::Result.new(
          compatible?: false,
          error: stderr.strip.presence || "Process exited with status #{status.exitstatus}"
        )
      end

      parsed = JSON.parse(stdout)
      DirectResolver::Result.new(
        compatible?: parsed["compatible"],
        error: parsed["error"],
        specs: parsed["specs"]
      )
    rescue => e
      DirectResolver::Result.new(compatible?: false, error: e.message)
    end
  end
end
