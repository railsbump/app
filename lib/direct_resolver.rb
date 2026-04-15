# frozen_string_literal: true

require "bundler"
require "bundler/source/metadata"

class DirectResolver
  Result = Struct.new(:compatible?, :error, :specs, keyword_init: true) do
    def resolved_version(gem_name)
      specs&.dig(gem_name)
    end
  end

  TargetRuntime = Struct.new(
    :ruby_version,
    :rubygems_version,
    :bundler_version,
    :platform,
    keyword_init: true
  ) do
    def ruby_version_object
      Bundler::RubyVersion.new(ruby_version, nil, "ruby", ruby_version)
    end

    def local_platform
      return Gem::Platform::RUBY if platform.nil? || platform == "ruby"
      platform.is_a?(Gem::Platform) ? platform : Gem::Platform.new(platform)
    end
  end

  # Subclass of Bundler's own Source::Metadata that provides specs at target
  # runtime versions instead of the running process's versions.
  class TargetMetadataSource < Bundler::Source::Metadata
    def initialize(runtime)
      @runtime = runtime
    end

    def specs
      @specs ||= Bundler::Index.build do |idx|
        idx << Gem::Specification.new("Ruby\0", @runtime.ruby_version_object.gem_version)
        idx << Gem::Specification.new("RubyGems\0", @runtime.rubygems_version) do |s|
          s.required_rubygems_version = Gem::Requirement.default
        end
        idx << Gem::Specification.new do |s|
          s.name     = "bundler"
          s.version  = Gem::Version.new(@runtime.bundler_version)
          s.platform = Gem::Platform::RUBY
          s.summary  = "Synthetic Bundler spec for direct resolution"
          s.authors  = ["compatibility"]
        end

        idx.each { |s| s.source = self }
      end
    end
  end

  class EarliestVersionPromoter < Bundler::GemVersionPromoter
    def sort_versions(package, specs)
      super.reverse
    end
  end

  def initialize(
    rails_version:,
    ruby_version:,
    dependencies: {},
    rubygems_version: Gem::VERSION,
    bundler_version: Bundler::VERSION,
    platform: "ruby",
    promoter: :latest
  )
    @rails_version = rails_version
    @dependencies = dependencies.merge("rails" => "~> #{@rails_version}.0")
    @promoter_key = promoter
    @runtime = TargetRuntime.new(
      ruby_version: ruby_version,
      rubygems_version: rubygems_version,
      bundler_version: bundler_version,
      platform: platform
    )
  end

  def call
    Bundler.with_unbundled_env do
      Bundler.ui.silence do
        definition = build_definition
        definition.resolve_remotely!
        specs = definition.resolve
        versions = specs.each_with_object({}) { |s, h| h[s.name] = s.version.to_s }
        Result.new(compatible?: true, specs: versions)
      end
    end
  rescue Bundler::SolveFailure, Bundler::GemNotFound, Bundler::HTTPError, Bundler::CyclicDependencyError => e
    Result.new(compatible?: false, error: e.message)
  end

  private

  def build_definition
    source_list = Bundler::SourceList.new
    source_list.add_global_rubygems_remote("https://rubygems.org")
    source_list.instance_variable_set(:@metadata_source, TargetMetadataSource.new(@runtime))

    definition = Bundler::Definition.new(
      Pathname.new("/dev/null/Gemfile.lock"),
      user_dependencies,
      source_list,
      true,
      @runtime.ruby_version_object
    )

    # Definition#metadata_dependencies hardcodes Bundler::RubyVersion.system
    # and Gem::VERSION. Override to use target runtime versions.
    definition.instance_variable_set(:@metadata_dependencies, [
      Bundler::Dependency.new("Ruby\0", @runtime.ruby_version_object.gem_version),
      Bundler::Dependency.new("RubyGems\0", @runtime.rubygems_version),
    ])

    if @promoter_key == :earliest
      definition.instance_variable_set(:@gem_version_promoter, EarliestVersionPromoter.new)
    end

    definition
  end

  def user_dependencies
    @dependencies.map do |name, constraint|
      Bundler::Dependency.new(name, constraint.split(",").map(&:strip))
    end
  end
end
