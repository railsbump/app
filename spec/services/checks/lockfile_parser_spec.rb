require "rails_helper"

RSpec.describe Checks::LockfileParser, type: :service, new_check_flow: true do
  def lockfile_content(rails_version: "7.1.3", ruby: nil, bundler: "2.4.10")
    <<~LOCK
      GEM
        remote: https://rubygems.org/
        specs:
          rails (#{rails_version})

      PLATFORMS
        ruby

      DEPENDENCIES
        rails (= #{rails_version})
      #{ruby ? "\nRUBY VERSION\n   ruby #{ruby}\n" : ""}
      BUNDLED WITH
         #{bundler}
    LOCK
  end

  describe "#rails_version" do
    it "returns the major.minor of the rails spec" do
      parser = described_class.new(lockfile_content(rails_version: "7.1.3"))

      expect(parser.rails_version).to eq("7.1")
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
      parser = described_class.new(lockfile_content(ruby: "3.3.1p0"))

      expect(parser.ruby_version).to eq("3.3.1")
    end

    it "returns nil when RUBY VERSION is absent" do
      parser = described_class.new(lockfile_content)

      expect(parser.ruby_version).to be_nil
    end
  end

  describe "#bundler_version" do
    it "returns the BUNDLED WITH version" do
      parser = described_class.new(lockfile_content(bundler: "2.4.10"))

      expect(parser.bundler_version).to eq("2.4.10")
    end
  end

  describe "#specs" do
    it "exposes parsed specs from the lockfile" do
      parser = described_class.new(lockfile_content(rails_version: "7.1.3"))

      expect(parser.specs.map(&:name)).to include("rails")
    end
  end

  describe "#dependencies" do
    it "exposes top-level dependencies" do
      parser = described_class.new(lockfile_content)

      expect(parser.dependencies.keys).to include("rails")
    end
  end

  describe "#source_for" do
    let(:content) do
      <<~LOCK
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
    end

    it "returns the rubygems remote for gems sourced from rubygems.org" do
      parser = described_class.new(content)

      expect(parser.source_for("rake")).to eq("https://rubygems.org/")
    end

    it "returns nil when the gem is not in the lockfile" do
      parser = described_class.new(content)

      expect(parser.source_for("missing")).to be_nil
    end
  end
end
