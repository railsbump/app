require "rails_helper"

RSpec.describe Lockfiles::StartCheck, type: :job, new_check_flow: true do
  let(:rails_release) do
    FactoryBot.create(:rails_release,
      version: "7.2",
      minimum_ruby_version: "3.1.0",
      minimum_bundler_version: "2.3.22",
      minimum_rubygems_version: "3.3.3")
  end

  let(:content) do
    <<~LOCK
      GEM
        remote: https://rubygems.org/
        specs:
          rails (7.1.3)
          puma (6.4.0)

      PLATFORMS
        ruby

      DEPENDENCIES
        rails (= 7.1.3)
        puma

      BUNDLED WITH
         2.4.10
    LOCK
  end

  let(:lockfile) { FactoryBot.create(:lockfile, content: content, slug: nil) }

  before { allow(Checks::ResolveGem).to receive(:perform_bulk) }

  describe "#perform" do
    it "creates a LockfileCheck for the given rails_release" do
      expect do
        described_class.new.perform(lockfile.id, rails_release.id)
      end.to change(LockfileCheck, :count).by(1)

      expect(LockfileCheck.last.rails_release).to eq(rails_release)
    end

    it "bulk-enqueues ResolveGem jobs for all pending gem_checks" do
      described_class.new.perform(lockfile.id, rails_release.id)

      pending_ids = LockfileCheck.last.gem_checks.where(status: "pending").pluck(:id)
      expect(Checks::ResolveGem).to have_received(:perform_bulk).with(pending_ids.map { [_1] })
    end

    it "uses next_rails_release when rails_release_id is omitted" do
      described_class.new.perform(lockfile.id)

      expect(Checks::ResolveGem).not_to have_received(:perform_bulk)
    end

    it "does nothing when there is no next rails release" do
      lockfile_no_next = FactoryBot.create(:lockfile, content: content.gsub("7.1.3", "7.2.0"), slug: nil)

      expect do
        described_class.new.perform(lockfile_no_next.id, nil)
      end.not_to change(LockfileCheck, :count)
    end

    it "is a no-op when the lockfile has been deleted before the job runs" do
      id = lockfile.id
      lockfile.destroy

      expect { described_class.new.perform(id, rails_release.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
