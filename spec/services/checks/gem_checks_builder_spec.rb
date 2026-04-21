require "rails_helper"

RSpec.describe Checks::GemChecksBuilder, type: :service, new_check_flow: true do
  let(:lockfile) { FactoryBot.create(:lockfile, content: content) }
  let(:rails_release) { FactoryBot.create(:rails_release, version: "7.2", minimum_ruby_version: "3.1.0", minimum_bundler_version: "2.3.22") }
  let(:lockfile_check) do
    LockfileCheck.create!(lockfile: lockfile, rails_release: rails_release, status: "pending")
  end
  let(:parser) { Checks::LockfileParser.new(content) }

  let(:content) do
    <<~LOCK
      GEM
        remote: https://rubygems.org/
        specs:
          rails (7.1.3)
          rake (13.0.6)
          activesupport (7.1.3)
          devise (4.9.0)

      PLATFORMS
        ruby

      DEPENDENCIES
        rails (= 7.1.3)
        rake
        activesupport
        devise

      BUNDLED WITH
         2.4.10
    LOCK
  end

  describe "#call" do
    it "creates gem_checks for non-rails, non-rails-subgem deps" do
      described_class.new(lockfile_check, parser).call

      names = lockfile_check.gem_checks.pluck(:gem_name)
      expect(names).to contain_exactly("rake", "devise")
    end

    it "sets locked_version and source from the parser" do
      described_class.new(lockfile_check, parser).call

      rake = lockfile_check.gem_checks.find_by!(gem_name: "rake")
      expect(rake.locked_version).to eq("13.0.6")
      expect(rake.source).to eq("https://rubygems.org/")
      expect(rake.status).to eq("pending")
    end

    it "is idempotent — second run is a no-op" do
      described_class.new(lockfile_check, parser).call
      expect {
        described_class.new(lockfile_check, parser).call
      }.not_to change { lockfile_check.gem_checks.count }
    end

    it "does nothing when there are no non-rails dependencies" do
      bare = <<~LOCK
        GEM
          remote: https://rubygems.org/
          specs:
            rails (7.1.3)

        PLATFORMS
          ruby

        DEPENDENCIES
          rails (= 7.1.3)

        BUNDLED WITH
           2.4.10
      LOCK
      bare_parser = Checks::LockfileParser.new(bare)

      described_class.new(lockfile_check, bare_parser).call

      expect(lockfile_check.gem_checks).to be_empty
    end
  end
end
