require "rails_helper"

RSpec.describe Checks::DispatchPendingGemChecks, type: :service, new_check_flow: true do
  let(:lockfile) { FactoryBot.create(:lockfile) }
  let(:rails_release) { FactoryBot.create(:rails_release, version: "7.2") }
  let(:lockfile_check) do
    LockfileCheck.create!(lockfile: lockfile, rails_release: rails_release, status: "pending")
  end

  def build_gem_check(attrs = {})
    lockfile_check.gem_checks.create!({
      gem_name: "rake",
      status: "pending",
      locked_version: "13.0.6",
      source: GemCheck::RUBYGEMS_SOURCE
    }.merge(attrs))
  end

  describe "#call" do
    it "enqueues ResolveGem for resolvable gem_checks" do
      gc = build_gem_check
      allow(Checks::ResolveGem).to receive(:perform_async)

      described_class.new(lockfile_check).call

      expect(Checks::ResolveGem).to have_received(:perform_async).with(gc.id)
    end

    it "marks non-resolvable gem_checks complete/skipped in one update" do
      gc = build_gem_check(gem_name: "internal", source: "git://example.com/foo.git")
      allow(Checks::ResolveGem).to receive(:perform_async)

      described_class.new(lockfile_check).call

      gc.reload
      expect(gc.status).to eq("complete")
      expect(gc.result).to eq("skipped")
      expect(Checks::ResolveGem).not_to have_received(:perform_async)
    end

    it "ignores non-pending gem_checks" do
      build_gem_check(status: "complete", result: "compatible")
      allow(Checks::ResolveGem).to receive(:perform_async)

      described_class.new(lockfile_check).call

      expect(Checks::ResolveGem).not_to have_received(:perform_async)
    end
  end
end
