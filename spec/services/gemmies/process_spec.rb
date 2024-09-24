# spec/services/gemmies/process_spec.rb
require 'rails_helper'

RSpec.describe Gemmies::Process, type: :service, vcr: { record: :once } do
  describe '#call' do
    let(:gemmy) { FactoryBot.create(:gemmy, name: 'ombu_labs-auth') }
    let(:service) { described_class.new }

    before do
      FactoryBot.create(:rails_release, version: "7.1")
      FactoryBot.create(:rails_release, version: "7.2")

      allow(Compats::CheckUnchecked).to receive(:perform_async)

      service.call(gemmy.id)
      gemmy.reload
    end

    it 'updates dependencies for the gemmy' do
      deps = [{"devise"=>"~> 4.8.1", "omniauth"=>"~> 2.1.0", "omniauth-github"=>"~> 2.0.0", "omniauth-rails_csrf_protection"=>">= 0", "rails"=>">= 6.0"}, {"devise"=>"~> 4.8.1", "omniauth"=>"~> 2.1.0", "omniauth-github"=>"~> 2.0.0", "rails"=>">= 6.0"}]

      expect(gemmy.dependencies).to eq(deps)
    end

    it 'calls UpdateCompats with the gemmy' do
      expect(gemmy.compat_ids.size).to eq(4)
    end

    it 'enqueues Compats::CheckUnchecked job' do
      expect(Compats::CheckUnchecked).to have_received(:perform_async)
    end
  end
end