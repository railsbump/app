require "rails_helper"

RSpec.describe GemCheck, type: :model, new_check_flow: true do
  let(:gem_check) do
    FactoryBot.create(:gem_check, gem_name: "puma", locked_version: "6.0.0")
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

  describe "#resolve" do
    context "when the result is compatible with a higher version" do
      it "marks the gem_check upgrade_needed with the earliest compatible version" do
        result = DirectResolver::Result.new(compatible?: true, specs: { "puma" => "6.4.0" })

        gem_check.resolve(result)

        expect(gem_check.status).to eq("complete")
        expect(gem_check.result).to eq("upgrade_needed")
        expect(gem_check.earliest_compatible_version).to eq("6.4.0")
      end
    end

    context "when the result is compatible at the locked version" do
      it "marks the gem_check compatible" do
        result = DirectResolver::Result.new(compatible?: true, specs: { "puma" => "6.0.0" })

        gem_check.resolve(result)

        expect(gem_check.status).to eq("complete")
        expect(gem_check.result).to eq("compatible")
        expect(gem_check.earliest_compatible_version).to be_nil
      end
    end

    context "when the result is compatible without a resolved version" do
      it "marks the gem_check compatible" do
        result = DirectResolver::Result.new(compatible?: true, specs: {})

        gem_check.resolve(result)

        expect(gem_check.status).to eq("complete")
        expect(gem_check.result).to eq("compatible")
      end
    end

    context "when the result is incompatible" do
      it "marks the gem_check incompatible and stores the error" do
        result = DirectResolver::Result.new(compatible?: false, error: "Could not find gem 'puma'")

        gem_check.resolve(result)

        expect(gem_check.status).to eq("complete")
        expect(gem_check.result).to eq("incompatible")
        expect(gem_check.error_message).to eq("Could not find gem 'puma'")
      end

      it "truncates long error messages to 1000 chars" do
        result = DirectResolver::Result.new(compatible?: false, error: "x" * 2000)

        gem_check.resolve(result)

        expect(gem_check.error_message.length).to eq(1000)
      end

      it "handles a nil error" do
        result = DirectResolver::Result.new(compatible?: false, error: nil)

        gem_check.resolve(result)

        expect(gem_check.result).to eq("incompatible")
        expect(gem_check.error_message).to be_nil
      end
    end
  end

  describe "#check!" do
    it "runs the resolver and applies the result" do
      result = DirectResolver::Result.new(compatible?: true, specs: { "puma" => "6.0.0" })
      resolver = instance_double(Checks::GemResolver, call: result)
      allow(Checks::GemResolver).to receive(:new).with(gem_check).and_return(resolver)

      gem_check.check!

      expect(gem_check.status).to eq("complete")
      expect(gem_check.result).to eq("compatible")
    end
  end
end
