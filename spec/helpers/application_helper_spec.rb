require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#compats_status" do
    let(:rails_release) { FactoryBot.create(:rails_release) }
    let(:gemmy) { FactoryBot.create(:gemmy) }

    context "when gemmy is inaccessible" do
      let(:lockfile) { FactoryBot.build(:lockfile) }
      let(:inaccessible_gemmy) { InaccessibleGemmy.new(name: "test_gem", lockfile: lockfile) }

      it "returns :inconclusive" do
        compats = Compat.none
        expect(helper.compats_status(inaccessible_gemmy, compats)).to eq(:inconclusive)
      end
    end

    context "when compats have compatible ones" do
      let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: :compatible, status_determined_by: "test", checked_at: Time.current) }

      before do
        gemmy.update!(compat_ids: [compat.id])
      end

      it "returns :compatible" do
        compats = gemmy.compats
        expect(helper.compats_status(gemmy, compats)).to eq(:compatible)
      end
    end

    context "when compats are none" do
      it "returns :checking" do
        compats = Compat.none
        expect(helper.compats_status(gemmy, compats)).to eq(:checking)
      end
    end

    context "when compats have pending ones" do
      let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: :pending) }

      before { gemmy.update!(compat_ids: [compat.id]) }

      it "returns :checking" do
        compats = gemmy.compats
        expect(helper.compats_status(gemmy, compats)).to eq(:checking)
      end
    end

    context "when compats are incompatible" do
      let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: :incompatible, status_determined_by: "test", checked_at: Time.current) }

      before { gemmy.update!(compat_ids: [compat.id]) }

      it "returns :incompatible" do
        compats = gemmy.compats
        expect(helper.compats_status(gemmy, compats)).to eq(:incompatible)
      end
    end
  end

  describe "#compats_label_and_text" do
    let(:rails_release) { FactoryBot.create(:rails_release, version: "7.1") }
    let(:gemmy) { FactoryBot.create(:gemmy) }

    context "when gemmy is inaccessible and has inconclusive compats" do
      let(:lockfile) { FactoryBot.build(:lockfile) }
      let(:inaccessible_gemmy) { InaccessibleGemmy.new(name: "test_gem", lockfile: lockfile) }

      it "returns inconclusive label and message" do
        # Create a mock collection that responds to all needed methods
        compats = double("compats")
        inconclusive_collection = double("inconclusive")
        compatible_collection = double("compatible")
        pending_collection = double("pending")

        allow(inconclusive_collection).to receive(:any?).and_return(true)
        allow(compatible_collection).to receive(:none?).and_return(true)
        allow(pending_collection).to receive(:none?).and_return(true)

        allow(compats).to receive(:inconclusive).and_return(inconclusive_collection)
        allow(compats).to receive(:compatible).and_return(compatible_collection)
        allow(compats).to receive(:pending).and_return(pending_collection)

        label, text = helper.compats_label_and_text(compats, inaccessible_gemmy, rails_release)

        expect(label).to eq("inconclusive")
        expect(text).to include("can't determine compatibility")
        expect(text).to include(inaccessible_gemmy.name)
        expect(text).to include(rails_release.to_s)
      end
    end

    context "when compats are none" do
      it "returns checking label and message" do
        compats = Compat.none
        label, text = helper.compats_label_and_text(compats, gemmy, rails_release)

        expect(label).to eq("checking")
        expect(text).to include("still being checked")
        expect(text).to include(gemmy.name)
      end
    end

    context "when no compatible and no pending compats" do
      let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: :incompatible, status_determined_by: "test", checked_at: Time.current) }

      before do
        gemmy.update!(compat_ids: [compat.id])
      end

      it "returns none label and message" do
        compats = gemmy.compats
        label, text = helper.compats_label_and_text(compats, gemmy, rails_release)

        expect(label).to eq("none")
        expect(text).to include("No version")
        expect(text).to include(gemmy.name)
        expect(text).to include(rails_release.to_s)
      end
    end

    context "when no compatible but has pending compats" do
      let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: :pending) }

      before do
        gemmy.update!(compat_ids: [compat.id])
      end

      it "returns checking label and message" do
        compats = gemmy.compats
        label, text = helper.compats_label_and_text(compats, gemmy, rails_release)

        expect(label).to eq("checking")
        expect(text).to include("version")
        expect(text).to include("still being checked")
      end
    end

    context "when all compats are compatible" do
      let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: :compatible, status_determined_by: "test", checked_at: Time.current) }

      before do
        gemmy.update!(compat_ids: [compat.id])
      end

      it "returns all label and message" do
        compats = gemmy.compats
        label, text = helper.compats_label_and_text(compats, gemmy, rails_release)

        expect(label).to eq("all")
        expect(text).to include("All versions")
        expect(text).to include(gemmy.name)
        expect(text).to include("compatible")
      end
    end

    context "when some compats are compatible" do
      let(:compatible_compat) do
        FactoryBot.create(:compat, rails_release: rails_release, status: :pending).tap do |c|
          c.update!(status: :compatible, status_determined_by: "test", checked_at: Time.current, dependencies: { "test" => "~> 1.0" })
        end
      end
      let(:incompatible_compat) do
        FactoryBot.create(:compat, rails_release: rails_release, status: :pending).tap do |c|
          c.update!(status: :incompatible, status_determined_by: "test", checked_at: Time.current, dependencies: { "test" => "~> 2.0" })
        end
      end

      before do
        gemmy.update!(
          compat_ids: [compatible_compat.id, incompatible_compat.id],
          dependencies_and_versions: {
            JSON.generate(compatible_compat.dependencies) => ["1.0.0", "1.1.0"],
            JSON.generate(incompatible_compat.dependencies) => ["2.0.0"]
          }
        )
      end

      it "returns label and text for partial compatibility" do
        compats = gemmy.compats
        label, text = helper.compats_label_and_text(compats, gemmy, rails_release)

        expect(label).to be_present
        expect(text).to include("compatible")
        expect(text).to include(gemmy.name)
      end
    end
  end

  describe "#head_title" do
    it "returns the default title" do
      expect(helper.head_title).to eq("RailsBump.org: Rails Compatibility Checker Tool")
    end
  end

  describe "#display_gemmy_name" do
    context "when gemmy is accessible" do
      let(:gemmy) { FactoryBot.create(:gemmy) }

      it "returns a link to the gemmy" do
        result = helper.display_gemmy_name(gemmy)
        expect(result).to include(gemmy.name)
        expect(result).to include('href')
      end
    end

    context "when gemmy is not accessible" do
      let(:lockfile) { FactoryBot.build(:lockfile) }
      let(:inaccessible_gemmy) { InaccessibleGemmy.new(name: "test_gem", lockfile: lockfile) }

      it "returns just the name without link" do
        result = helper.display_gemmy_name(inaccessible_gemmy)
        expect(result).to eq(inaccessible_gemmy.name)
        expect(result).not_to include('href')
      end
    end
  end

  describe "#meta_description" do
    it "returns the meta description" do
      description = helper.meta_description
      expect(description).to include("RailsBump")
      expect(description).to include("compatibility")
    end
  end
end
