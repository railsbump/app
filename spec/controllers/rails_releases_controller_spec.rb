require "rails_helper"

RSpec.describe RailsReleasesController, type: :controller do
  describe "GET #show" do
    let(:gemmy) { FactoryBot.create(:gemmy, name: "test_gem") }
    let!(:rails_release) { FactoryBot.create(:rails_release, version: "7.1") }

    it "assigns the gemmy" do
      get :show, params: { gemmy_id: gemmy.name, id: "rails-7-1" }
      expect(assigns(:gemmy)).to eq(gemmy)
    end

    it "assigns the rails_release" do
      get :show, params: { gemmy_id: gemmy.name, id: "rails-7-1" }
      expect(assigns(:rails_release)).to eq(rails_release)
    end

    it "converts the id parameter to version format" do
      FactoryBot.create(:rails_release, version: "7.2")
      get :show, params: { gemmy_id: gemmy.name, id: "rails-7-2" }
      expect(assigns(:rails_release).version).to eq("7.2")
    end

    context "when gemmy does not exist" do
      it "raises an error" do
        expect do
          get :show, params: { gemmy_id: "nonexistent", id: "rails-7-1" }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when rails_release does not exist" do
      it "raises an error" do
        expect do
          get :show, params: { gemmy_id: gemmy.name, id: "rails-1-9" }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
