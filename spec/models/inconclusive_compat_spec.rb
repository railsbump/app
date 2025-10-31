require "rails_helper"

RSpec.describe InconclusiveCompat, type: :model do
  let(:rails_release) { FactoryBot.create(:rails_release) }
  let(:inconclusive_compat) do
    compat = InconclusiveCompat.create!(
      rails_release: rails_release,
      dependencies: { "gem" => "~> 1.0" },
      status: :pending
    )
    # Update to inconclusive with required fields
    compat.update!(
      status: :inconclusive,
      status_determined_by: "test",
      checked_at: Time.current
    )
    compat
  end

  describe "#compatible" do
    it "returns an empty array" do
      expect(inconclusive_compat.compatible).to eq([])
    end
  end

  describe "#inconclusive" do
    it "returns an array containing itself" do
      expect(inconclusive_compat.inconclusive).to eq([inconclusive_compat])
    end
  end

  describe "#pending" do
    it "returns an empty array" do
      expect(inconclusive_compat.pending).to eq([])
    end
  end

  describe "#none?" do
    it "returns true" do
      expect(inconclusive_compat.none?).to be true
    end
  end
end
