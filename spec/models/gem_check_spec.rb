require "rails_helper"

RSpec.describe GemCheck, type: :model, new_check_flow: true do
  let(:gem_check) { build(:gem_check, gem_name: "puma", locked_version: "6.0.0") }

  describe ".create_for!" do
    let(:lockfile_check) { FactoryBot.create(:lockfile_check) }

    def locked_gem(name: "puma", version: "6.0.0", source: "https://rubygems.org/")
      Lockfile::Parsed::LockedGem.new(name: name, version: version, source: source)
    end

    it "creates a pending GemCheck when the gem is resolvable" do
      gem = locked_gem(source: "https://rubygems.org/", version: "6.0.0")

      gem_check = described_class.create_for!(lockfile_check: lockfile_check, gem: gem)

      expect(gem_check).to be_persisted
      expect(gem_check.status).to eq("pending")
      expect(gem_check.result).to be_nil
    end

    it "creates a complete+skipped GemCheck when the gem is not resolvable" do
      gem = locked_gem(source: "https://github.com/example/foo.git", version: "6.0.0")

      gem_check = described_class.create_for!(lockfile_check: lockfile_check, gem: gem)

      expect(gem_check.status).to eq("complete")
      expect(gem_check.result).to eq("skipped")
    end

    it "marks a gem with no version as skipped" do
      gem = locked_gem(version: nil, source: nil)

      gem_check = described_class.create_for!(lockfile_check: lockfile_check, gem: gem)

      expect(gem_check.status).to eq("complete")
      expect(gem_check.result).to eq("skipped")
    end

    it "populates gem_name, locked_version, and source from the LockedGem" do
      gem = locked_gem(name: "puma", version: "6.0.0", source: "https://rubygems.org/")

      gem_check = described_class.create_for!(lockfile_check: lockfile_check, gem: gem)

      expect(gem_check.gem_name).to eq("puma")
      expect(gem_check.locked_version).to eq("6.0.0")
      expect(gem_check.source).to eq("https://rubygems.org/")
    end

    it "is idempotent across repeated calls with the same lockfile_check and gem_name" do
      gem = locked_gem

      first = described_class.create_for!(lockfile_check: lockfile_check, gem: gem)
      second = described_class.create_for!(lockfile_check: lockfile_check, gem: gem)

      expect(second).to eq(first)
      expect(lockfile_check.gem_checks.count).to eq(1)
    end

    it "returns the GemCheck" do
      result = described_class.create_for!(lockfile_check: lockfile_check, gem: locked_gem)

      expect(result).to be_a(GemCheck)
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
