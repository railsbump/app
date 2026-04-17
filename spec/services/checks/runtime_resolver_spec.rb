require "rails_helper"

RSpec.describe Checks::RuntimeResolver, type: :service do
  let(:rails_release) do
    FactoryBot.create(:rails_release,
      version: "7.2",
      minimum_ruby_version: "3.1.0",
      minimum_bundler_version: "2.3.22")
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
    before { stub_rails_gems_api }

    it "returns a Runtime data object with ruby, rubygems, and bundler versions" do
      runtime = described_class.new(rails_release:, lockfile_ruby: nil, lockfile_bundler: nil).call

      expect(runtime).to be_a(Checks::RuntimeResolver::Runtime)
      expect(runtime.ruby_version).to eq("3.1.0")
      expect(runtime.bundler_version).to eq("2.3.22")
    end

    it "takes the max of the lockfile version and the release minimum" do
      runtime = described_class.new(rails_release:, lockfile_ruby: "3.3.1", lockfile_bundler: "2.5.0").call

      expect(runtime.ruby_version).to eq("3.3.1")
      expect(runtime.bundler_version).to eq("2.5.0")
    end

    it "falls back to the Gems API minimums when the release has none" do
      rails_release.update_columns(minimum_ruby_version: nil, minimum_bundler_version: nil)

      runtime = described_class.new(rails_release:, lockfile_ruby: nil, lockfile_bundler: "2.4.10").call

      expect(runtime.ruby_version).to eq("3.1.0")
      expect(runtime.bundler_version).to eq("2.4.10")
    end

    it "resolves rubygems_version from the chosen ruby version" do
      allow(RubyRubygemsVersion).to receive(:for).with("3.1.0").and_return("3.3.7")

      runtime = described_class.new(rails_release:, lockfile_ruby: nil, lockfile_bundler: nil).call

      expect(runtime.rubygems_version).to eq("3.3.7")
    end

    it "picks the highest patch version from the Gems API when multiple exist" do
      allow(Gems).to receive(:versions).with("rails").and_return([
        { "number" => "7.2.0", "prerelease" => false },
        { "number" => "7.2.1", "prerelease" => false },
        { "number" => "7.2.2.rc1", "prerelease" => true }
      ])
      allow(Gems::V2).to receive(:info).with("rails", "7.2.1").and_return(
        "ruby_version" => ">= 3.1.0",
        "dependencies" => {
          "runtime" => [{ "name" => "bundler", "requirements" => ">= 2.3.22" }]
        }
      )

      runtime = described_class.new(rails_release:, lockfile_ruby: nil, lockfile_bundler: nil).call

      expect(runtime.ruby_version).to eq("3.1.0")
    end
  end
end
