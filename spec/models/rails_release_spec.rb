require "rails_helper"

RSpec.describe RailsRelease, type: :model do
  subject { described_class.new(version: "6.0") }

  describe "valid?" do
    it "returns true" do
      expect(subject).to be_valid
    end
  end
end