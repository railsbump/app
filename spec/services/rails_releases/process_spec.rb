require "rails_helper"

RSpec.describe RailsReleases::Process, type: :service do
  let(:rails_release) { FactoryBot.create(:rails_release) }
  let(:service) { described_class.new }

  describe "#call" do
    before do
      FactoryBot.create(:gemmy, name: "gem1")
      FactoryBot.create(:gemmy, name: "gem2")
      allow(Gemmies::UpdateCompats).to receive(:perform_async)
      allow(Compats::CheckUnchecked).to receive(:perform_async)
    end

    it "schedules UpdateCompats for all gemmies" do
      service.call(rails_release.id)

      Gemmy.find_each do |gemmy|
        expect(Gemmies::UpdateCompats).to have_received(:perform_async).with(gemmy.id)
      end
    end

    it "schedules CheckUnchecked" do
      service.call(rails_release.id)

      expect(Compats::CheckUnchecked).to have_received(:perform_async)
    end
  end
end

