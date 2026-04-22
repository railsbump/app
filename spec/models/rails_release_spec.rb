require "rails_helper"

RSpec.describe RailsRelease, type: :model do
  subject { described_class.new(version: "6.0") }

  describe "valid?" do
    it "returns true" do
      expect(subject).to be_valid
    end
  end

  describe ".next_after" do
    let!(:release_6_1) { FactoryBot.create(:rails_release, version: "6.1") }
    let!(:release_7_0) { FactoryBot.create(:rails_release, version: "7.0") }
    let!(:release_7_2) { FactoryBot.create(:rails_release, version: "7.2") }

    it "returns the next release after the given version" do
      expect(described_class.next_after("7.0")).to eq(release_7_2)
    end

    it "excludes the given version itself" do
      expect(described_class.next_after("6.1")).to eq(release_7_0)
    end

    it "returns the earliest release when the given version precedes every release" do
      expect(described_class.next_after("5.0")).to eq(release_6_1)
    end

    it "returns nil when no newer release exists" do
      expect(described_class.next_after("7.2")).to be_nil
    end
  end
end