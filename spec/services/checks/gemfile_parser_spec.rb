require "rails_helper"

RSpec.describe Checks::GemfileParser, type: :service, new_check_flow: true do
  def build_lockfile(content)
    FactoryBot.create(:lockfile, content: content)
  end

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

  def stub_rails_gems_api(patch: "7.2.0", ruby_requirement: ">= 3.1.0", bundler_requirement: ">= 2.3.22")
    allow(Gems).to receive(:versions).with("rails").and_return([
      { "number" => patch, "prerelease" => false }
    ])
    allow(Gems::V2).to receive(:info).with("rails", patch).and_return(
      "ruby_version" => ruby_requirement,
      "dependencies" => {
        "runtime" => [{ "name" => "bundler", "requirements" => bundler_requirement }]
      }
    )
  end

  describe "#call" do
    context "when the lockfile has no rails spec" do
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

      it "returns nil" do
        lockfile = build_lockfile(content)

        expect(described_class.new(lockfile).call).to be_nil
      end
    end

    context "when no RailsRelease is greater than the lockfile's Rails version" do
      it "returns nil" do
        FactoryBot.create(:rails_release, version: "7.0")
        lockfile = build_lockfile(lockfile_content(rails_version: "7.1.3"))

        expect(described_class.new(lockfile).call).to be_nil
      end
    end

    context "when a newer RailsRelease exists" do
      let!(:next_release) do
        FactoryBot.create(:rails_release,
          version: "7.2",
          minimum_ruby_version: "3.1.0",
          minimum_bundler_version: "2.3.22")
      end

      before do
        FactoryBot.create(:rails_release, version: "7.0")
        stub_rails_gems_api(patch: "7.2.0")
      end

      it "creates a pending lockfile_check for the next release" do
        lockfile = build_lockfile(lockfile_content(rails_version: "7.1.3"))

        lockfile_check = described_class.new(lockfile).call

        expect(lockfile_check).to be_persisted
        expect(lockfile_check.rails_release).to eq(next_release)
        expect(lockfile_check.status).to eq("pending")
      end

      it "uses release minimums when they are set" do
        lockfile = build_lockfile(lockfile_content(rails_version: "7.1.3", ruby: "3.0.0p0", bundler: "2.3.0"))

        lockfile_check = described_class.new(lockfile).call

        expect(lockfile_check.ruby_version).to eq("3.1.0")
        expect(lockfile_check.bundler_version).to eq("2.3.22")
      end

      it "takes the max of the lockfile version and the release minimum" do
        lockfile = build_lockfile(lockfile_content(rails_version: "7.1.3", ruby: "3.3.1p0", bundler: "2.5.0"))

        lockfile_check = described_class.new(lockfile).call

        expect(lockfile_check.ruby_version).to eq("3.3.1")
        expect(lockfile_check.bundler_version).to eq("2.5.0")
      end

      it "falls back to the Gems API minimums when the release has none" do
        next_release.update_columns(minimum_ruby_version: nil, minimum_bundler_version: nil)
        stub_rails_gems_api(patch: "7.2.0", ruby_requirement: ">= 3.1.0", bundler_requirement: ">= 2.3.22")
        lockfile = build_lockfile(lockfile_content(rails_version: "7.1.3"))

        lockfile_check = described_class.new(lockfile).call

        expect(lockfile_check.ruby_version).to eq("3.1.0")
        expect(lockfile_check.bundler_version).to eq("2.4.10")
      end

      it "resolves rubygems_version from the chosen ruby version" do
        allow(RubyRubygemsVersion).to receive(:for).with("3.1.0").and_return("3.3.7")
        lockfile = build_lockfile(lockfile_content(rails_version: "7.1.3"))

        lockfile_check = described_class.new(lockfile).call

        expect(lockfile_check.rubygems_version).to eq("3.3.7")
      end

      it "is idempotent across calls" do
        lockfile = build_lockfile(lockfile_content(rails_version: "7.1.3"))

        first = described_class.new(lockfile).call
        second = described_class.new(lockfile).call

        expect(second).to eq(first)
        expect(lockfile.lockfile_checks.count).to eq(1)
      end
    end
  end

end
