require "rails_helper"

RSpec.describe LockfileCheck, type: :model, new_check_flow: true do
  let(:rails_release) do
    FactoryBot.create(:rails_release,
      version: "7.2",
      minimum_ruby_version: "3.1.0",
      minimum_bundler_version: "2.3.22",
      minimum_rubygems_version: "3.3.3")
  end

  def build_lockfile_content(rails_version: "7.1.3", ruby: "3.3.0", bundler: "2.5.0")
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

      RUBY VERSION
         ruby #{ruby}

      BUNDLED WITH
         #{bundler}
    LOCK
  end

  def create_lockfile(**kwargs)
    FactoryBot.create(:lockfile, content: build_lockfile_content(**kwargs), slug: nil)
  end

  describe ".create_for!" do
    it "creates a persisted LockfileCheck with status pending" do
      lockfile = create_lockfile

      lockfile_check = described_class.create_for!(lockfile: lockfile, rails_release: rails_release)

      expect(lockfile_check).to be_persisted
      expect(lockfile_check.status).to eq("pending")
    end

    it "populates the runtime versions from TargetRuntime" do
      lockfile = create_lockfile(ruby: "3.3.0", bundler: "2.5.0")

      lockfile_check = described_class.create_for!(lockfile: lockfile, rails_release: rails_release)

      expect(lockfile_check.ruby_version).to eq("3.3.0")
      expect(lockfile_check.bundler_version).to eq("2.5.0")
      expect(lockfile_check.rubygems_version).to eq("3.5.3")
    end

    it "creates a GemCheck for each non-rails gem in the lockfile" do
      lockfile = create_lockfile

      lockfile_check = described_class.create_for!(lockfile: lockfile, rails_release: rails_release)

      expect(lockfile_check.gem_checks.pluck(:gem_name)).to contain_exactly("puma")
    end

    it "is idempotent across repeated calls with the same lockfile and rails_release" do
      lockfile = create_lockfile

      first = described_class.create_for!(lockfile: lockfile, rails_release: rails_release)
      second = described_class.create_for!(lockfile: lockfile, rails_release: rails_release)

      expect(second).to eq(first)
      expect(lockfile.lockfile_checks.count).to eq(1)
    end

    it "returns the LockfileCheck" do
      lockfile = create_lockfile

      result = described_class.create_for!(lockfile: lockfile, rails_release: rails_release)

      expect(result).to be_a(LockfileCheck)
    end
  end

  describe "#enqueue_gem_checks" do
    before { allow(Checks::ResolveGem).to receive(:perform_async) }

    it "enqueues Checks::ResolveGem for each pending gem_check" do
      lockfile_check = FactoryBot.create(:lockfile_check)
      pending_check = FactoryBot.create(:gem_check,
        lockfile_check: lockfile_check,
        gem_name: "puma",
        status: "pending")

      lockfile_check.enqueue_gem_checks

      expect(Checks::ResolveGem).to have_received(:perform_async).with(pending_check.id)
    end

    it "does not enqueue complete gem_checks" do
      lockfile_check = FactoryBot.create(:lockfile_check)
      FactoryBot.create(:gem_check,
        lockfile_check: lockfile_check,
        gem_name: "puma",
        status: "complete",
        result: "skipped")

      lockfile_check.enqueue_gem_checks

      expect(Checks::ResolveGem).not_to have_received(:perform_async)
    end
  end
end
