require 'rails_helper'

RSpec.describe RubygemsController, type: :controller do

  before(:each) do
    allow_any_instance_of(Rubygem).to receive(:gem_exists_in_rubygem_dot_org).and_return(true)
  end

  describe 'api' do
    let!(:devise) { FactoryGirl.create :rubygem, status_rails4: 'ready', status_rails5: 'unknown' }

    context 'when checking for a valid gem' do
      it 'should return json with details' do
        get :show, id: devise.name, format: :json
        expect(response.status).to eq 200
        hash = JSON.parse(response.body)
        expect(hash['name']).to eq(devise.name)
        expect(hash['status_rails4']).to eq('ready')
        expect(hash['status_rails5']).to eq('unknown')
        expect(hash['notes_rails4']).to eq(devise.notes_rails4)
        expect(hash['notes_rails5']).to eq(devise.notes_rails5)
      end
    end

    context "when checking for an invalid gem" do
      it 'should return empty json' do
        get :show, id: 'some other name', format: :json
        expect(response.status).to eq 200
        hash = JSON.parse(response.body)
        expect(hash).to be_truthy
      end
    end
  end
end

