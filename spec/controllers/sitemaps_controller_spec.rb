require "rails_helper"

RSpec.describe SitemapsController, type: :controller do
  describe "GET #show" do
    context "when FOG_URL is set" do
      let(:sitemap_url) { "https://s3.us-east-1.amazonaws.com/railsbump.org" }
      let(:sitemap_content) { "<?xml version='1.0'?><urlset></urlset>" }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("FOG_URL").and_return(sitemap_url)
        allow(URI).to receive(:open).with("#{sitemap_url}/sitemap.xml").and_return(StringIO.new(sitemap_content))
      end

      it "fetches and returns the sitemap" do
        get :show
        expect(response.body).to eq(sitemap_content)
        expect(response.content_type).to include("application/xml")
        expect(response.headers["Content-Disposition"]).to include("inline")
      end

      it "returns 200 OK" do
        get :show
        expect(response).to have_http_status(:ok)
      end
    end

    context "when FOG_URL is not set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("FOG_URL").and_return(nil)
      end

      it "returns 404 Not Found" do
        get :show
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
