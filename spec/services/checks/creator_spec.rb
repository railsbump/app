require "rails_helper"

RSpec.describe Checks::Creator, type: :service, new_check_flow: true do
  def build_lockfile(content)
    FactoryBot.create(:lockfile, content: content)
  end

  def lockfile_content(rails_version: "7.1.3", ruby: nil, bundler: "2.4.10", extra_specs: [], extra_deps: [])
    specs_block = ["    rails (#{rails_version})"] + extra_specs.map { |s| "    #{s}" }
    deps_block = ["  rails (= #{rails_version})"] + extra_deps.map { |d| "  #{d}" }

    <<~LOCK
      GEM
        remote: https://rubygems.org/
        specs:
      #{specs_block.join("\n")}

      PLATFORMS
        ruby

      DEPENDENCIES
      #{deps_block.join("\n")}
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

      it "returns a :no_rails result" do
        lockfile = build_lockfile(content)

        result = described_class.new(lockfile).call

        expect(result.success?).to be(false)
        expect(result.reason).to eq(:no_rails)
      end
    end

    context "when no RailsRelease is greater than the lockfile's Rails version" do
      it "returns a :no_newer_release result" do
        FactoryBot.create(:rails_release, version: "7.0")
        lockfile = build_lockfile(lockfile_content(rails_version: "7.1.3"))

        result = described_class.new(lockfile).call

        expect(result.success?).to be(false)
        expect(result.reason).to eq(:no_newer_release)
      end
    end

    context "when a newer RailsRelease exists" do
      let!(:next_release) do
        FactoryBot.create(:rails_release,
          version: "7.2",
          minimum_ruby_version: "3.1.0",
          minimum_bundler_version: "2.3.22")
      end

      let(:content) do
        lockfile_content(
          rails_version: "7.1.3",
          extra_specs: ["rake (13.0.6)", "activesupport (7.1.3)"],
          extra_deps: ["rake", "activesupport"]
        )
      end

      before do
        stub_rails_gems_api(patch: "7.2.0")
      end

      it "returns a successful :ok result with the lockfile_check" do
        lockfile = build_lockfile(content)

        result = described_class.new(lockfile).call

        expect(result.success?).to be(true)
        expect(result.reason).to eq(:ok)
        expect(result.lockfile_check.rails_release).to eq(next_release)
      end

      it "creates gem_checks for non-rails deps only" do
        lockfile = build_lockfile(content)

        result = described_class.new(lockfile).call

        names = result.lockfile_check.gem_checks.pluck(:gem_name)
        expect(names).to contain_exactly("rake")
      end

      it "dispatches ResolveGem for resolvable gem_checks" do
        lockfile = build_lockfile(content)
        allow(Checks::ResolveGem).to receive(:perform_async)

        described_class.new(lockfile).call

        expect(Checks::ResolveGem).to have_received(:perform_async).once
      end

      it "is idempotent across calls" do
        lockfile = build_lockfile(content)
        allow(Checks::ResolveGem).to receive(:perform_async)

        described_class.new(lockfile).call
        described_class.new(lockfile).call

        expect(lockfile.lockfile_checks.count).to eq(1)
        expect(lockfile.lockfile_checks.first.gem_checks.count).to eq(1)
      end
    end
  end
end
