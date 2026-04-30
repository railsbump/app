require "rails_helper"

RSpec.describe Lockfile::Parsed, type: :model, new_check_flow: true do
  def lockfile_content(rails_version: "7.1.3", ruby: nil, bundler: "2.4.10", extra_deps: "")
    <<~LOCK
      GEM
        remote: https://rubygems.org/
        specs:
          rails (#{rails_version})
          puma (6.4.0)

      PLATFORMS
        ruby

      DEPENDENCIES
        rails (= #{rails_version})
        puma
      #{extra_deps}#{ruby ? "\nRUBY VERSION\n   ruby #{ruby}\n" : ""}
      BUNDLED WITH
         #{bundler}
    LOCK
  end

  describe "#rails_version" do
    it "returns the full version of the rails spec" do
      parsed = described_class.new(lockfile_content(rails_version: "7.1.3"))

      expect(parsed.rails_version).to eq("7.1.3")
    end

    it "falls back to the railties version when rails is not declared directly" do
      content = <<~LOCK
        GEM
          remote: https://rubygems.org/
          specs:
            actionpack (8.0.5)
            activerecord (8.0.5)
            railties (8.0.5)

        PLATFORMS
          ruby

        DEPENDENCIES
          railties (~> 8.0.0)

        BUNDLED WITH
           2.5.0
      LOCK

      expect(described_class.new(content).rails_version).to eq("8.0.5")
    end

    it "returns nil when there is no rails spec" do
      content = <<~LOCK
        GEM
          remote: https://rubygems.org/
          specs:
            rake (13.0.6)

        PLATFORMS
          ruby

        DEPENDENCIES
          rake

        BUNDLED WITH
           2.4.10
      LOCK

      expect(described_class.new(content).rails_version).to be_nil
    end
  end

  describe "#ruby_version" do
    it "extracts the x.y.z version from RUBY VERSION" do
      parsed = described_class.new(lockfile_content(ruby: "3.3.1p0"))

      expect(parsed.ruby_version).to eq("3.3.1")
    end

    it "handles RUBY VERSION without a patch suffix" do
      parsed = described_class.new(lockfile_content(ruby: "3.3.1"))

      expect(parsed.ruby_version).to eq("3.3.1")
    end

    it "returns nil when RUBY VERSION is absent" do
      parsed = described_class.new(lockfile_content)

      expect(parsed.ruby_version).to be_nil
    end
  end

  describe "#bundler_version" do
    it "returns the BUNDLED WITH version" do
      parsed = described_class.new(lockfile_content(bundler: "2.4.10"))

      expect(parsed.bundler_version).to eq("2.4.10")
    end
  end

  describe "#gems" do
    it "returns LockedGems for top-level dependencies, excluding rails" do
      parsed = described_class.new(lockfile_content)

      expect(parsed.gems.map(&:name)).to contain_exactly("puma")
    end

    it "populates name, version, and source from the matching spec" do
      parsed = described_class.new(lockfile_content)

      puma = parsed.gems.find { |g| g.name == "puma" }

      expect(puma.version).to eq("6.4.0")
      expect(puma.source).to eq("https://rubygems.org/")
    end

    it "yields a LockedGem with nil version and source when the dependency has no matching spec" do
      parsed = described_class.new(lockfile_content(extra_deps: "  mystery_gem!\n"))

      mystery_gem = parsed.gems.find { |g| g.name == "mystery_gem" }

      expect(mystery_gem).not_to be_nil
      expect(mystery_gem.version).to be_nil
      expect(mystery_gem.source).to be_nil
    end
  end

  describe Lockfile::Parsed::LockedGem do
    describe "#resolvable?" do
      it "is true for an https rubygems source with a locked version" do
        gem = described_class.new(name: "puma", version: "1.0.0", source: "https://rubygems.org/")

        expect(gem.resolvable?).to be true
      end

      it "is true for an http rubygems source with a locked version" do
        gem = described_class.new(name: "puma", version: "1.0.0", source: "http://rubygems.org/")

        expect(gem.resolvable?).to be true
      end

      it "is false when the source is not rubygems" do
        gem = described_class.new(name: "puma", version: "1.0.0", source: "https://example.com/")

        expect(gem.resolvable?).to be false
      end

      it "is false when the version is missing" do
        gem = described_class.new(name: "puma", version: nil, source: "https://rubygems.org/")

        expect(gem.resolvable?).to be false
      end
    end
  end
end
