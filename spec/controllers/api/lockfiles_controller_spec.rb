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
      it "creates a lockfile and returns 202 with slug, status, and polling instructions" do
        expect do
          post :create, params: { lockfile: { content: content } }, as: :json
        end.to change(Lockfile, :count).by(1)

        expect(response).to have_http_status(:accepted)
        expect(response.headers["Retry-After"]).to match(/\A\d+\z/)
        expect(response.headers["Location"]).to include("/lockfiles/#{Lockfile.last.slug}")

        json = JSON.parse(response.body)
        expect(json["slug"]).to eq(Lockfile.last.slug)
        expect(json["status"]).to eq("pending")
        expect(json["retry_after_seconds"]).to be_a(Integer).and be_between(30, 600)
        expect(json["status_url"]).to include("/lockfiles/#{Lockfile.last.slug}")
        expect(json["message"]).to include("GET")
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

  describe "GET #show" do
    it "returns the lockfile with its checks and gem_checks" do
      lockfile = FactoryBot.create(:lockfile)
      rails_release = FactoryBot.create(:rails_release, version: "7.2")
      lockfile_check = FactoryBot.create(:lockfile_check, lockfile: lockfile, rails_release: rails_release, status: "pending")
      FactoryBot.create(:gem_check, lockfile_check: lockfile_check, gem_name: "puma", locked_version: "6.4.0", status: "complete", result: "compatible")

      get :show, params: { id: lockfile.slug }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["slug"]).to eq(lockfile.slug)
      expect(json["status"]).to eq("pending")
      expect(json["lockfile_checks"].size).to eq(1)
      check = json["lockfile_checks"].first
      expect(check["rails_version"]).to eq("7.2")
      expect(check["status"]).to eq("pending")
      expect(check["gem_checks"].size).to eq(1)
      gc = check["gem_checks"].first
      expect(gc["name"]).to eq("puma")
      expect(gc["locked_version"]).to eq("6.4.0")
      expect(gc["status"]).to eq("complete")
      expect(gc["result"]).to eq("compatible")
    end

    it "returns 404 when slug is unknown" do
      get :show, params: { id: "nonexistent" }, as: :json

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end
end
