require "rails_helper"

RSpec.describe TargetRuntime, type: :model do
  let(:rails_release) do
    FactoryBot.create(:rails_release,
      version: "7.2",
      minimum_ruby_version: "3.1.0",
      minimum_bundler_version: "2.3.22",
      minimum_rubygems_version: "3.3.3")
  end

  def lockfile_stub(ruby: nil, bundler: nil)
    instance_double(Lockfile, ruby_version: ruby, bundler_version: bundler)
  end

  describe "#ruby_version" do
    it "returns the rails release minimum when the lockfile has no ruby version" do
      runtime = described_class.new(lockfile: lockfile_stub, rails_release: rails_release)

      expect(runtime.ruby_version).to eq("3.1.0")
    end

    it "returns the lockfile version when it exceeds the rails release minimum" do
      runtime = described_class.new(lockfile: lockfile_stub(ruby: "3.3.1"), rails_release: rails_release)

      expect(runtime.ruby_version).to eq("3.3.1")
    end

    it "returns the rails release minimum when it exceeds the lockfile version" do
      runtime = described_class.new(lockfile: lockfile_stub(ruby: "3.0.0"), rails_release: rails_release)

      expect(runtime.ruby_version).to eq("3.1.0")
    end

    it "returns nil when neither source provides a ruby version" do
      release = FactoryBot.create(:rails_release, version: "7.2", minimum_ruby_version: nil)
      runtime = described_class.new(lockfile: lockfile_stub, rails_release: release)

      expect(runtime.ruby_version).to be_nil
    end
  end

  describe "#bundler_version" do
    it "returns the rails release minimum when the lockfile has no bundler version" do
      runtime = described_class.new(lockfile: lockfile_stub, rails_release: rails_release)

      expect(runtime.bundler_version).to eq("2.3.22")
    end

    it "returns the lockfile version when it exceeds the rails release minimum" do
      runtime = described_class.new(lockfile: lockfile_stub(bundler: "2.5.0"), rails_release: rails_release)

      expect(runtime.bundler_version).to eq("2.5.0")
    end

    it "returns the rails release minimum when it exceeds the lockfile version" do
      runtime = described_class.new(lockfile: lockfile_stub(bundler: "2.0.0"), rails_release: rails_release)

      expect(runtime.bundler_version).to eq("2.3.22")
    end
  end

  describe "#rubygems_version" do
    it "derives the rubygems version from the resolved ruby via floor lookup" do
      # Ruby 3.3.3 has no exact entry; floor is 3.3.0 → 3.5.3
      release = FactoryBot.create(:rails_release,
        version: "7.2",
        minimum_ruby_version: "3.3.3",
        minimum_rubygems_version: "1.0.0")

      runtime = described_class.new(lockfile: lockfile_stub, rails_release: release)

      expect(runtime.rubygems_version).to eq("3.5.3")
    end

    it "uses an exact match when the ruby version is in the table" do
      release = FactoryBot.create(:rails_release,
        version: "7.2",
        minimum_ruby_version: "3.3.0",
        minimum_rubygems_version: "1.0.0")

      runtime = described_class.new(lockfile: lockfile_stub, rails_release: release)

      expect(runtime.rubygems_version).to eq("3.5.3")
    end

    it "returns the rails release minimum when it exceeds the ruby-derived version" do
      # Ruby 2.7.0 → rubygems 3.1.2, but release pins 3.5.0
      release = FactoryBot.create(:rails_release,
        version: "7.2",
        minimum_ruby_version: "2.7.0",
        minimum_rubygems_version: "3.5.0")

      runtime = described_class.new(lockfile: lockfile_stub, rails_release: release)

      expect(runtime.rubygems_version).to eq("3.5.0")
    end

    it "falls back to the rails release minimum when ruby predates the lookup table" do
      # Ruby 1.8.7 is below the table floor of 1.9.3; lookup returns nil
      release = FactoryBot.create(:rails_release,
        version: "3.0",
        minimum_ruby_version: "1.8.7",
        minimum_rubygems_version: "1.3.6")

      runtime = described_class.new(lockfile: lockfile_stub, rails_release: release)

      expect(runtime.rubygems_version).to eq("1.3.6")
    end
  end
end
