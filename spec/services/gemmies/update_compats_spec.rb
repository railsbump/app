require "rails_helper"

RSpec.describe Gemmies::UpdateCompats do
  describe "#call" do
    let(:gemmy) { FactoryBot.create :gemmy }
    
    before do
      @rails_release = FactoryBot.create :rails_release
      Gemmies::UpdateDependenciesAndVersions.call(gemmy)
    end

    it "creates a compat for each rails release and dependency" do
      described_class.call(gemmy)

      expect(@rails_release.compats.count).to eq 5
    end
  end
end