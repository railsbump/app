require "rails_helper"

RSpec.describe RailsRelease, type: :model do
  subject { described_class.new(version: "6.0") }

  describe "valid?" do
    it "returns true" do
      expect(subject).to be_valid
    end
  end

  describe ".newer_than" do
    let!(:release_6_1) { FactoryBot.create(:rails_release, version: "6.1") }
    let!(:release_7_0) { FactoryBot.create(:rails_release, version: "7.0") }
    let!(:release_7_2) { FactoryBot.create(:rails_release, version: "7.2") }

    it "returns releases newer than the given version, ordered ascending" do
      expect(described_class.newer_than("7.0")).to eq([release_7_2])
    end

    it "excludes the given version itself" do
      expect(described_class.newer_than("7.2")).to be_empty
    end

    it "returns all releases when the given version precedes every release" do
      expect(described_class.newer_than("5.0")).to eq([release_6_1, release_7_0, release_7_2])
    end
  end
end