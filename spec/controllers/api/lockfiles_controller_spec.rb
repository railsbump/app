require "rails_helper"

RSpec.describe API::LockfilesController, type: :controller, new_check_flow: true do
  describe "POST #create" do
    let(:content) do
      <<~LOCK
        GEM
          remote: https://rubygems.org/
          specs:
            rails (7.1.3)
            puma (6.4.0)

        PLATFORMS
          ruby

        DEPENDENCIES
          rails (= 7.1.3)
          puma

        BUNDLED WITH
           2.4.10
      LOCK
    end

    context "with valid content" do
      it "creates a lockfile and returns 202 with slug" do
        expect do
          post :create, params: { lockfile: { content: content } }, as: :json
        end.to change(Lockfile, :count).by(1)

        expect(response).to have_http_status(:accepted)
        json = JSON.parse(response.body)
        expect(json["slug"]).to eq(Lockfile.last.slug)
      end

      it "triggers run_check! on the lockfile" do
        expect_any_instance_of(Lockfile).to receive(:run_check!)

        post :create, params: { lockfile: { content: content } }, as: :json
      end
    end

    context "with invalid content" do
      it "returns 422 with errors" do
        expect do
          post :create, params: { lockfile: { content: "not a lockfile" } }, as: :json
        end.not_to change(Lockfile, :count)

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end

    context "with missing content" do
      it "returns 422 with errors" do
        post :create, params: { lockfile: { content: "" } }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end
end
