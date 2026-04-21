require "rails_helper"

RSpec.describe Checks::GemResolver, type: :service, new_check_flow: true do
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

  describe "#call" do
    it "invokes DirectResolver::Subprocess with the lockfile runtime and earliest promoter" do
      subprocess = instance_double(DirectResolver::Subprocess, call: "result")

      expect(DirectResolver::Subprocess).to receive(:new).with(
        rails_version: "7.2",
        ruby_version: "3.3.0",
        rubygems_version: "3.5.0",
        bundler_version: "2.5.0",
        dependencies: { "puma" => ">= 6.0.0" },
        promoter: :earliest
      ).and_return(subprocess)

      expect(described_class.new(gem_check).call).to eq("result")
    end
  end
end
