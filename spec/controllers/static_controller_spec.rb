require "rails_helper"

RSpec.describe StaticController, type: :controller do
  describe "GET #robots" do
    it "returns 200 OK" do
      get :robots
      expect(response).to have_http_status(:ok)
    end

    it "renders the robots template" do
      get :robots
      expect(response).to render_template(:robots)
    end
  end
end
