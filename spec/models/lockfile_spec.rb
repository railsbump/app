require "rails_helper"

RSpec.describe Lockfile, type: :model, new_check_flow: true do
  def build_lockfile(rails_version: "7.1.3")
    content = <<~LOCK
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

      BUNDLED WITH
         2.4.10
    LOCK
    build(:lockfile, content: content, slug: nil)
  end

  def create_lockfile(**kwargs)
    build_lockfile(**kwargs).tap(&:save!)
  end

  describe "#next_rails_release" do
    it "returns the next RailsRelease after the lockfile's rails version" do
      FactoryBot.create(:rails_release, version: "7.0") # previous release
      next_release = FactoryBot.create(:rails_release, version: "7.2")

      expect(build_lockfile(rails_version: "7.1.3").next_rails_release).to eq(next_release)
    end

    it "returns nil when there is no newer RailsRelease" do
      FactoryBot.create(:rails_release, version: "7.0") # previous release

      expect(build_lockfile(rails_version: "7.1.3").next_rails_release).to be_nil
    end

    it "returns nil when the lockfile has no rails spec" do
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
      FactoryBot.create(:rails_release, version: "7.2")
      lockfile = build(:lockfile, content: content, slug: nil)

      expect(lockfile.next_rails_release).to be_nil
    end
  end

  describe "#run_check!" do
    let!(:next_release) do
      FactoryBot.create(:rails_release,
        version: "7.2",
        minimum_ruby_version: "3.1.0",
        minimum_bundler_version: "2.3.22",
        minimum_rubygems_version: "3.3.3")
    end

    before { allow(Lockfiles::StartCheck).to receive(:perform_async) }

    it "enqueues Lockfiles::StartCheck for the next RailsRelease" do
      lockfile = create_lockfile(rails_version: "7.1.3")

      lockfile.run_check!

      expect(Lockfiles::StartCheck).to have_received(:perform_async).with(lockfile.id, next_release.id)
    end

    it "does nothing when there is no newer RailsRelease" do
      lockfile = create_lockfile(rails_version: "8.0.0")

      lockfile.run_check!

      expect(Lockfiles::StartCheck).not_to have_received(:perform_async)
    end

    it "accepts an explicit rails_release argument, overriding next_rails_release" do
      other_release = FactoryBot.create(:rails_release,
        version: "8.0",
        minimum_ruby_version: "3.2.0",
        minimum_bundler_version: "2.5.20",
        minimum_rubygems_version: "3.2.3")
      lockfile = create_lockfile(rails_version: "7.1.3")

      lockfile.run_check!(rails_release: other_release)

      expect(Lockfiles::StartCheck).to have_received(:perform_async).with(lockfile.id, other_release.id)
    end
  end
end
