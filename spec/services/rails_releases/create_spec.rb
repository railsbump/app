require "rails_helper"

RSpec.describe RailsReleases::Create, type: :service do
  let(:service) { described_class.new }

  describe "#call" do
    before { allow(RailsReleases::Process).to receive(:perform_async) }

    context "with a valid stable version" do
      it "creates a new RailsRelease" do
        expect do
          service.call("7.1.0")
        end.to change(RailsRelease, :count).by(1)
      end

      it "creates release with major.minor version" do
        rails_release = service.call("7.1.5")
        expect(rails_release.version).to eq("7.1")
      end

      it "schedules Process job" do
        rails_release = service.call("7.1.0")
        expect(RailsReleases::Process).to have_received(:perform_async).with(rails_release.id)
      end

      it "returns the created RailsRelease" do
        result = service.call("7.1.0")
        expect(result).to be_a(RailsRelease)
        expect(result.version).to eq("7.1")
      end
    end

    context "when version already exists" do
      before do
        FactoryBot.create(:rails_release, version: "7.1")
      end

      it "does not create a duplicate" do
        expect do
          service.call("7.1.0")
        end.not_to change(RailsRelease, :count)
      end

      it "does not schedule Process job" do
        service.call("7.1.0")
        expect(RailsReleases::Process).not_to have_received(:perform_async)
      end

      it "returns nil" do
        expect(service.call("7.1.0")).to be_nil
      end
    end

    context "with a prerelease version" do
      it "does not create a release" do
        expect do
          service.call("7.1.0.alpha")
        end.not_to change(RailsRelease, :count)
      end

      it "returns nil" do
        expect(service.call("7.1.0.alpha")).to be_nil
      end
    end

    context "with version less than 2.3" do
      it "does not create a release" do
        expect do
          service.call("2.2.0")
        end.not_to change(RailsRelease, :count)
      end

      it "returns nil" do
        expect(service.call("2.2.0")).to be_nil
      end
    end

    context "with version 2.3" do
      it "creates a release" do
        expect do
          service.call("2.3.0")
        end.to change(RailsRelease, :count).by(1)
      end
    end

    context "with version without minor" do
      it "treats minor as 0" do
        rails_release = service.call("7")
        expect(rails_release.version).to eq("7.0")
      end
    end
  end
end
