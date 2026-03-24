require "rails_helper"

RSpec.describe "Gemmies JSON API", type: :request do
  include FactoryBot::Syntax::Methods

  describe "GET /gems/:id.json" do
    context "when the gem exists with compats" do
      let(:rails_71) { create(:rails_release, version: "7.1") }
      let(:rails_72) { create(:rails_release, version: "7.2") }
      let(:gemmy) { create(:gemmy, name: "devise") }
      let!(:compatible_compat) do
        create(:compat,
          rails_release: rails_71,
          dependencies: { "devise" => "~> 4.9" },
          status: :compatible,
          checked_at: Time.current,
          status_determined_by: "bundler"
        )
      end
      let!(:incompatible_compat) do
        create(:compat,
          rails_release: rails_72,
          dependencies: { "devise" => "~> 3.0" },
          status: :incompatible,
          checked_at: Time.current,
          status_determined_by: "bundler"
        )
      end

      before do
        gemmy.update!(compat_ids: [compatible_compat.id, incompatible_compat.id])
      end

      it "returns gem name and compatibility per Rails version" do
        get "/gems/devise.json"

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")

        json = JSON.parse(response.body)
        expect(json["name"]).to eq("devise")
        expect(json["compatibility"]).to be_an(Array)
        expect(json["compatibility"].size).to eq(2)

        compat_71 = json["compatibility"].find { |c| c["rails_version"] == "7.1" }
        expect(compat_71["status"]).to eq("compatible")
        expect(compat_71["compats"]).to be_an(Array)
        expect(compat_71["compats"].first["dependencies"]).to eq({ "devise" => "~> 4.9" })

        compat_72 = json["compatibility"].find { |c| c["rails_version"] == "7.2" }
        expect(compat_72["status"]).to eq("incompatible")
      end
    end

    context "when the gem has pending compats" do
      let(:rails_release) { create(:rails_release, version: "7.1") }
      let(:gemmy) { create(:gemmy, name: "sidekiq") }
      let!(:pending_compat) do
        create(:compat,
          rails_release: rails_release,
          dependencies: { "sidekiq" => "~> 7.0" },
          status: :pending
        )
      end

      before do
        gemmy.update!(compat_ids: [pending_compat.id])
      end

      it "returns checking status" do
        get "/gems/sidekiq.json"

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        compat = json["compatibility"].first
        expect(compat["status"]).to eq("checking")
      end
    end

    context "when the gem has no compats for a Rails version" do
      let!(:rails_release) { create(:rails_release, version: "7.1") }
      let!(:gemmy) { create(:gemmy, name: "tiny_gem", compat_ids: []) }

      it "returns checking status for that version" do
        get "/gems/tiny_gem.json"

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        compat = json["compatibility"].first
        expect(compat["rails_version"]).to eq("7.1")
        expect(compat["status"]).to eq("checking")
      end
    end
  end
end
