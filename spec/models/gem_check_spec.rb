require "rails_helper"

RSpec.describe GemCheck, type: :model, new_check_flow: true do
  let(:rails_release) { FactoryBot.create(:rails_release, version: "7.2") }
  let(:lockfile_check) do
    FactoryBot.create(:lockfile_check,
      rails_release: rails_release,
      ruby_version: "3.3.0",
      rubygems_version: "3.5.0",
      bundler_version: "2.5.0")
  end
  let(:gem_check) do
    FactoryBot.create(:gem_check,
      lockfile_check: lockfile_check,
      gem_name: "puma",
      locked_version: "6.0.0")
  end

  describe "#resolvable?" do
    it "is true for rubygems source with a locked version" do
      gem_check.source = GemCheck::RUBYGEMS_SOURCE
      gem_check.locked_version = "1.0.0"
      expect(gem_check.resolvable?).to be true
    end

    it "is false when source is not rubygems" do
      gem_check.source = "https://example.com/"
      expect(gem_check.resolvable?).to be false
    end

    it "is false when locked_version is missing" do
      gem_check.locked_version = nil
      expect(gem_check.resolvable?).to be false
    end
  end

  describe "#resolver" do
    it "builds a DirectResolver::Subprocess with the lockfile runtime and earliest promoter" do
      expect(DirectResolver::Subprocess).to receive(:new).with(
        rails_version: "7.2",
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

      it "truncates long error messages to 1000 chars" do
        stub_resolver(DirectResolver::Result.new(compatible?: false, error: "x" * 2000))

        gem_check.perform!

        expect(gem_check.error_message.length).to eq(1000)
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
