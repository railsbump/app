require "rails_helper"

RSpec.describe Compats::Check, type: :service do
  let(:compat) { FactoryBot.create(:compat, rails_release: rails_release, status: "pending", dependencies: []) }
  let(:rails_release) { FactoryBot.create(:rails_release) }
  let(:service) { described_class.new }

  describe "#call" do
    context "when compat is already checked" do
      before { allow(compat).to receive(:checked?).and_return(true) }

      it "raises an error" do
        expect { service.call(compat) }.to raise_error(Compats::Check::Error, "Compat is already checked.")
      end
    end

    context "when compat is not checked" do
      before do
        allow(compat).to receive(:checked!)
      end

      it "calls all private methods and marks compat as checked" do
        service.call(compat)

        expect(compat).to have_received(:checked!)
      end
    end
  end

  xdescribe '#check_with_bundler_locally', vcr: { record: :all } do
    before do
      FactoryBot.create(:rails_release, version: "7.1")
      FactoryBot.create(:rails_release, version: "7.2")

      Gemmies::UpdateDependenciesAndVersions.call(gemmy)
      Gemmies::UpdateCompats.call(gemmy.id)
      gemmy.reload
    end

    context 'when using the skunk gem' do
      let(:gemmy) { FactoryBot.create(:gemmy, name: 'skunk') }

      it 'marks the compat as compatible' do
        gemmy.compat_ids.each do |compat_id|
          compat = Compat.find(compat_id)
          service = described_class.new
          service.compat = compat
          service.send(:check_with_bundler_locally)

          expect(compat.status).to eq('compatible')
          expect(compat.status_determined_by).to eq('bundler_local')
        end
      end
    end

    context 'when using the win32-api gem' do
      let(:gemmy) { FactoryBot.create(:gemmy, name: 'win32-api') }

      it 'marks the compat as inconclusive' do
        gemmy.compat_ids.each do |compat_id|
          compat = Compat.find(compat_id)
          service = described_class.new
          service.compat = compat
          service.send(:check_with_bundler_locally)

          expect(compat.status).to eq('inconclusive')
          expect(compat.status_determined_by).to eq('bundler_local')
        end
      end
    end
  end
end