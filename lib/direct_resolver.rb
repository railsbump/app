# frozen_string_literal: true

require "bundler"
require "bundler/resolver"
require "bundler/resolver/base"
require "bundler/source/rubygems"

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

  class MetadataSource
    def initialize(runtime)
      @runtime = runtime
    end

    def specs
      @specs ||= Bundler::Index.build do |index|
        index << Gem::Specification.new("Ruby\0", @runtime.ruby_version_object.gem_version)
        index << Gem::Specification.new("RubyGems\0", @runtime.rubygems_version) do |spec|
          spec.required_rubygems_version = Gem::Requirement.default
        end
        index << Gem::Specification.new do |spec|
          spec.name = "bundler"
          spec.version = Gem::Version.new(@runtime.bundler_version)
          spec.platform = Gem::Platform::RUBY
          spec.summary = "Synthetic Bundler spec for direct resolution"
          spec.authors = ["compatibility"]
        end

        index.each { |spec| spec.source = self }
      end
    end

    def options = {}
    def to_s = "synthetic metadata source"

    def ==(other)
      other.class == self.class
    end
    alias eql? ==

    def hash
      self.class.hash
    end
  end

  class EarliestVersionPromoter < Bundler::GemVersionPromoter
    def sort_versions(package, specs)
      super.reverse
    end
  end

  PROMOTERS = {
    latest: -> { Bundler::GemVersionPromoter.new },
    earliest: -> { EarliestVersionPromoter.new }
  }.freeze

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
        specs = Bundler::Resolver.new(resolution_base, gem_version_promoter, nil).start
        versions = specs.each_with_object({}) { |s, h| h[s.name] = s.version.to_s }
        Result.new(compatible?: true, specs: versions)
      end
    end
  rescue Bundler::SolveFailure, Bundler::GemNotFound, Bundler::HTTPError, Bundler::CyclicDependencyError => e
    Result.new(compatible?: false, error: e.message)
  end

  private

  def resolution_base
    Bundler::Resolver::Base.new(
      source_requirements,
      expanded_dependencies,
      Bundler::SpecSet.new([]),
      [@runtime.local_platform],
      locked_specs: Bundler::SpecSet.new([]),
      unlock: true,
      prerelease: gem_version_promoter.pre?,
      prefer_local: false,
      new_platforms: []
    )
  end

  def source_requirements
    {
      default: rubygems_source,
      "Ruby\0" => metadata_source,
      "RubyGems\0" => metadata_source,
      "bundler" => metadata_source,
    }
  end

  def expanded_dependencies
    [
      Bundler::Dependency.new("Ruby\0", @runtime.ruby_version_object.gem_version),
      Bundler::Dependency.new("RubyGems\0", @runtime.rubygems_version),
      Bundler::Dependency.new("bundler", @runtime.bundler_version),
      *user_dependencies,
    ]
  end

  def user_dependencies
    @dependencies.map do |name, constraint|
      Bundler::Dependency.new(name, constraint.split(",").map(&:strip))
    end
  end

  def rubygems_source
    @rubygems_source ||= begin
      source = Bundler::Source::Rubygems.new("remotes" => ["https://rubygems.org"])
      source.remote!
      source.add_dependency_names(@dependencies.keys)
      source
    end
  end

  def metadata_source
    @metadata_source ||= MetadataSource.new(@runtime)
  end

  def gem_version_promoter
    @gem_version_promoter ||= PROMOTERS.fetch(@promoter_key).call
  end
end
