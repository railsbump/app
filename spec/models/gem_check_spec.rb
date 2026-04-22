require "rails_helper"

RSpec.describe GemCheck, type: :model, new_check_flow: true do
  let(:gem_check) { build(:gem_check, gem_name: "puma", locked_version: "6.0.0") }

  describe "#resolvable?" do
    it "is true for rubygems source with a locked version" do
      expect(GemCheck.new(source: GemCheck::RUBYGEMS_SOURCE, locked_version: "1.0.0").resolvable?).to be true
    end

    it "is false when source is not rubygems" do
      expect(GemCheck.new(source: "https://example.com/", locked_version: "1.0.0").resolvable?).to be false
    end

    it "is false when locked_version is missing" do
      expect(GemCheck.new(source: GemCheck::RUBYGEMS_SOURCE, locked_version: nil).resolvable?).to be false
    end
  end

  describe "#resolver" do
    it "builds a DirectResolver::Subprocess with the lockfile runtime and earliest promoter" do
      expect(DirectResolver::Subprocess).to receive(:new).with(
        rails_version: "7.1",
        ruby_version: "3.3.0",
        rubygems_version: "3.5.0",
        bundler_version: "2.5.0",
        dependencies: { "puma" => ">= 6.0.0" },
        promoter: :earliest
      )

      gem_check.resolver
    end
  end

  describe "#perform!" do
    def stub_resolver(result)
      resolver = instance_double(DirectResolver::Subprocess, call: result)
      allow(gem_check).to receive(:resolver).and_return(resolver)
    end

    context "when the result is compatible with a higher version" do
      it "marks the gem_check upgrade_needed with the earliest compatible version" do
        stub_resolver(DirectResolver::Result.new(compatible?: true, specs: { "puma" => "6.4.0" }))

        gem_check.perform!

        expect(gem_check.status).to eq("complete")
        expect(gem_check.result).to eq("upgrade_needed")
        expect(gem_check.earliest_compatible_version).to eq("6.4.0")
      end
    end

    context "when the result is compatible at the locked version" do
      it "marks the gem_check compatible" do
        stub_resolver(DirectResolver::Result.new(compatible?: true, specs: { "puma" => "6.0.0" }))

        gem_check.perform!

        expect(gem_check.status).to eq("complete")
        expect(gem_check.result).to eq("compatible")
        expect(gem_check.earliest_compatible_version).to be_nil
      end
    end

    context "when the result is compatible without a resolved version" do
      it "marks the gem_check compatible" do
        stub_resolver(DirectResolver::Result.new(compatible?: true, specs: {}))

        gem_check.perform!

        expect(gem_check.status).to eq("complete")
        expect(gem_check.result).to eq("compatible")
      end
    end

    context "when the result is incompatible" do
      it "marks the gem_check incompatible and stores the error" do
        stub_resolver(DirectResolver::Result.new(compatible?: false, error: "Could not find gem 'puma'"))

        gem_check.perform!

        expect(gem_check.status).to eq("complete")
        expect(gem_check.result).to eq("incompatible")
        expect(gem_check.error_message).to eq("Could not find gem 'puma'")
      end

      it "handles a nil error" do
        stub_resolver(DirectResolver::Result.new(compatible?: false, error: nil))

        gem_check.perform!

        expect(gem_check.result).to eq("incompatible")
        expect(gem_check.error_message).to be_nil
      end
    end
  end
end
