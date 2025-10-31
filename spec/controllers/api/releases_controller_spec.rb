require "rails_helper"

RSpec.describe API::ReleasesController, type: :controller do
  describe "POST #create" do
    context "when name is 'rails'" do
      before { allow(RailsReleases::Create).to receive(:perform_async) }

      it "schedules RailsReleases::Create with the version" do
        post :create, params: { name: "rails", version: "7.1.0" }

        expect(RailsReleases::Create).to have_received(:perform_async).with("7.1.0")
      end

      it "returns 200 OK" do
        post :create, params: { name: "rails", version: "7.1.0" }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when name is a gem name" do
      let(:gemmy) { FactoryBot.create(:gemmy, name: "test_gem") }

      before { allow(Gemmies::Process).to receive(:perform_async) }

      it "schedules Gemmies::Process for the gemmy" do
        post :create, params: { name: gemmy.name, version: "1.0.0" }

        expect(Gemmies::Process).to have_received(:perform_async).with(gemmy.id)
      end

      it "returns 200 OK" do
        post :create, params: { name: gemmy.name, version: "1.0.0" }
        expect(response).to have_http_status(:ok)
      end

      context "when gemmy does not exist" do
        it "does not schedule processing" do
          post :create, params: { name: "nonexistent_gem", version: "1.0.0" }

          expect(Gemmies::Process).not_to have_received(:perform_async)
        end

        it "returns 200 OK" do
          post :create, params: { name: "nonexistent_gem", version: "1.0.0" }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
