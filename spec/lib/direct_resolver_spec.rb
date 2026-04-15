# frozen_string_literal: true

require "rails_helper"

RSpec.describe DirectResolver do
  describe DirectResolver::Result do
    it "exposes compatible?, error, and specs" do
      result = described_class.new(compatible?: true, specs: { "foo" => "1.0" })

      expect(result.compatible?).to be true
      expect(result.error).to be_nil
      expect(result.resolved_version("foo")).to eq("1.0")
    end

    it "exposes error for incompatible results" do
      result = described_class.new(compatible?: false, error: "nope")

      expect(result.compatible?).to be false
      expect(result.error).to eq("nope")
      expect(result.resolved_version("foo")).to be_nil
    end
  end

  describe DirectResolver::TargetRuntime do
    let(:runtime) do
      described_class.new(
        ruby_version: "3.4.2",
        rubygems_version: "3.5.0",
        bundler_version: "2.5.0",
        platform: "ruby"
      )
    end

    it "builds a RubyVersion object with the target version" do
      expect(runtime.ruby_version_object).to be_a(Bundler::RubyVersion)
      expect(runtime.ruby_version_object.gem_version).to eq(Gem::Version.new("3.4.2"))
    end

    it "returns Gem::Platform::RUBY for ruby platform" do
      expect(runtime.local_platform).to eq(Gem::Platform::RUBY)
    end

    it "returns Gem::Platform::RUBY for nil platform" do
      runtime = described_class.new(
        ruby_version: "3.4.2",
        rubygems_version: "3.5.0",
        bundler_version: "2.5.0",
        platform: nil
      )

      expect(runtime.local_platform).to eq(Gem::Platform::RUBY)
    end
  end

  describe DirectResolver::TargetMetadataSource do
    let(:runtime) do
      DirectResolver::TargetRuntime.new(
        ruby_version: "3.2.0",
        rubygems_version: "3.4.0",
        bundler_version: "2.4.0",
        platform: "ruby"
      )
    end

    let(:source) { described_class.new(runtime) }

    it "is a Bundler::Source::Metadata subclass" do
      expect(source).to be_a(Bundler::Source::Metadata)
    end

    it "provides specs for Ruby, RubyGems, and bundler at target versions" do
      specs = source.specs

      ruby_spec = specs.search("Ruby\0").first
      expect(ruby_spec.version).to eq(Gem::Version.new("3.2.0"))

      rubygems_spec = specs.search("RubyGems\0").first
      expect(rubygems_spec.version).to eq(Gem::Version.new("3.4.0"))

      bundler_spec = specs.search("bundler").first
      expect(bundler_spec.version).to eq(Gem::Version.new("2.4.0"))
    end

    it "sets itself as the source on all specs" do
      source.specs.each do |spec|
        expect(spec.source).to eq(source)
      end
    end

    it "inherits equality and options from Source::Metadata" do
      other = described_class.new(runtime)
      expect(source).to eq(other)
      expect(source.hash).to eq(other.hash)
      expect(source.options).to eq({})
    end
  end

  describe DirectResolver::EarliestVersionPromoter do
    it "is a GemVersionPromoter subclass that reverses sort_versions" do
      promoter = described_class.new

      expect(promoter).to be_a(Bundler::GemVersionPromoter)

      dummy_result = [3, 1, 2]
      allow_any_instance_of(Bundler::GemVersionPromoter).to receive(:sort_versions).and_return(dummy_result)

      expect(promoter.sort_versions(nil, nil)).to eq([2, 1, 3])
    end
  end

  describe "#call" do
    let(:ruby_version) { "3.4.2" }
    let(:rails_version) { "8.0" }

    it "builds a Definition and resolves through it" do
      resolver = DirectResolver.new(
        rails_version: rails_version,
        ruby_version: ruby_version,
        dependencies: { "rack" => ">= 2.0" }
      )

      mock_spec_set = instance_double(Bundler::SpecSet)
      allow(mock_spec_set).to receive(:each_with_object).and_return(
        { "rack" => "3.1.0", "rails" => "8.0.1" }
      )

      mock_definition = instance_double(Bundler::Definition)
      allow(mock_definition).to receive(:resolve_remotely!)
      allow(mock_definition).to receive(:resolve).and_return(mock_spec_set)

      allow(resolver).to receive(:build_definition).and_return(mock_definition)

      result = resolver.call

      expect(result.compatible?).to be true
      expect(result.specs).to eq({ "rack" => "3.1.0", "rails" => "8.0.1" })
    end

    it "catches SolveFailure and returns incompatible Result" do
      resolver = DirectResolver.new(
        rails_version: rails_version,
        ruby_version: ruby_version,
        dependencies: { "rack" => ">= 2.0" }
      )

      mock_definition = instance_double(Bundler::Definition)
      allow(mock_definition).to receive(:resolve_remotely!)
        .and_raise(Bundler::SolveFailure.new("no solution"))

      allow(resolver).to receive(:build_definition).and_return(mock_definition)

      result = resolver.call

      expect(result.compatible?).to be false
      expect(result.error).to eq("no solution")
    end

    it "catches GemNotFound and returns incompatible Result" do
      resolver = DirectResolver.new(
        rails_version: rails_version,
        ruby_version: ruby_version,
        dependencies: { "rack" => ">= 2.0" }
      )

      mock_definition = instance_double(Bundler::Definition)
      allow(mock_definition).to receive(:resolve_remotely!)
        .and_raise(Bundler::GemNotFound, "gem not found")

      allow(resolver).to receive(:build_definition).and_return(mock_definition)

      result = resolver.call

      expect(result.compatible?).to be false
      expect(result.error).to eq("gem not found")
    end
  end

  describe "#build_definition" do
    it "creates a Definition with SourceList, target metadata, and user deps" do
      resolver = DirectResolver.new(
        rails_version: "8.0",
        ruby_version: "3.4.2",
        dependencies: { "rack" => ">= 2.0" }
      )

      definition = resolver.send(:build_definition)

      expect(definition).to be_a(Bundler::Definition)

      # Metadata source is our TargetMetadataSource
      source_list = definition.instance_variable_get(:@sources)
      expect(source_list.metadata_source).to be_a(DirectResolver::TargetMetadataSource)

      # Metadata dependencies use target versions, not system versions
      metadata_deps = definition.instance_variable_get(:@metadata_dependencies)
      ruby_dep = metadata_deps.find { |d| d.name == "Ruby\0" }
      expect(ruby_dep.requirement).to eq(Gem::Requirement.new("= 3.4.2"))
    end

    it "injects EarliestVersionPromoter when promoter is :earliest" do
      resolver = DirectResolver.new(
        rails_version: "8.0",
        ruby_version: "3.4.2",
        promoter: :earliest
      )

      definition = resolver.send(:build_definition)
      promoter = definition.instance_variable_get(:@gem_version_promoter)

      expect(promoter).to be_a(DirectResolver::EarliestVersionPromoter)
    end

    it "uses default GemVersionPromoter when promoter is :latest" do
      resolver = DirectResolver.new(
        rails_version: "8.0",
        ruby_version: "3.4.2",
        promoter: :latest
      )

      definition = resolver.send(:build_definition)
      promoter = definition.instance_variable_get(:@gem_version_promoter)

      expect(promoter).to be_nil
    end
  end

  describe "rails dependency" do
    it "merges rails constraint from rails_version" do
      resolver = DirectResolver.new(
        rails_version: "7.2",
        ruby_version: "3.3.0",
        dependencies: { "devise" => ">= 4.0" }
      )

      deps = resolver.send(:user_dependencies)
      rails_dep = deps.find { |d| d.name == "rails" }

      expect(rails_dep.requirement.to_s).to eq("~> 7.2.0")
    end
  end
end
